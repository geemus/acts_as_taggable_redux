module ActiveRecord
  module Acts #:nodoc:
    module Taggable #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_taggable(options = {})
          has_many :taggings, :as => :taggable, :dependent => :destroy, :include => :tag
          has_many :tags, :through => :taggings, :order => 'name asc'
          
          after_save :update_tags
          
          extend ActiveRecord::Acts::Taggable::SingletonMethods          
          include ActiveRecord::Acts::Taggable::InstanceMethods
        end
      end
      
      module SingletonMethods
        # Pass a tag string, returns taggables that match the tag string.
        # 
        # Options:
        #   :match - Match taggables matching :all or :any of the tags, defaults to :any
        #   :user  - Limits results to those owned by a particular user
        def find_tagged_with(tags, options = {})
          tagged_with_scope(tags, options) do
            find(:all, :select =>  "DISTINCT #{table_name}.*")
          end
        end
        
        def tagged_with_scope(tags, options={})
          options.assert_valid_keys([:match, :user])
          
          tags = Tag.parse(tags)
          return [] if tags.empty?
          
          group = "#{table_name}_taggings.taggable_id HAVING COUNT(#{table_name}_taggings.taggable_id) = #{tags.size}" if options[:match] == :all
          conditions = sanitize_sql(["#{table_name}_tags.name IN (?)", tags])
          conditions += sanitize_sql([" AND #{table_name}_taggings.user_id = ?", options[:user]]) if options[:user]
          
          find_parameters = {
            :joins  =>  "LEFT OUTER JOIN #{Tagging.table_name} #{table_name}_taggings ON #{table_name}_taggings.taggable_id = #{table_name}.#{primary_key} AND #{table_name}_taggings.taggable_type = '#{name}' " +
                        "LEFT OUTER JOIN #{Tag.table_name} #{table_name}_tags ON #{table_name}_tags.id = #{table_name}_taggings.tag_id",
            :conditions => conditions,
            :group  =>  group            
          }
          
          with_scope(:find => find_parameters) { yield }          
        end
        
        # Pass a tag string, returns taggables that match the tag string for a particular user.
        # 
        # Options:
        #   :match - Match taggables matching :all or :any of the tags, defaults to :any
        def find_tagged_with_by_user(tags, user, options = {})
          options.assert_valid_keys([:match])
          find_tagged_with(tags, {:match => options[:match], :user => user})
        end
      end
      
      module InstanceMethods
        def tag_list=(new_tag_list)
          unless tag_list == new_tag_list
            @new_tag_list = new_tag_list
          end
        end
        
        def user_id=(new_user_id)
          @new_user_id = new_user_id
          super(new_user_id)
        end
        
        def tag_list(user = nil)
          unless user
            resiult = tags.collect { |tag| tag.name.include?(" ") ? %("#{tag.name}") : tag.name }.join(" ")
          else
            tags.delete_if { |tag| !user.tags.include?(tag) }.collect { |tag| tag.name.include?(" ") ? %("#{tag.name}") : tag.name }.join(" ")
          end
        end
        
        def update_tags
          if @new_tag_list
            Tag.transaction do
              unless @new_user_id
                taggings.destroy_all
              else
                taggings.find(:all, :conditions => "user_id = #{@new_user_id}").each do |tagging|
                  tagging.destroy
                end
              end
            
              Tag.parse(@new_tag_list).each do |name|
                Tag.find_or_create_by_name(name).tag(self, @new_user_id)
              end

              tags.reset
              taggings.reset
              @new_tag_list = nil
            end
          end
        end
      end
    end
  end
end
