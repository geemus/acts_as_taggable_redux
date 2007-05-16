module ActiveRecord
  module Acts #:nodoc:
    module Taggable #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_taggable(options = {})
          has_many :taggings, :as => :taggable, :dependent => :destroy, :include => :tag
          has_many :tags, :through => :taggings
          
          after_save :update_tags
          
          include ActiveRecord::Acts::Taggable::InstanceMethods
          extend ActiveRecord::Acts::Taggable::SingletonMethods
        end
      end
      
      module SingletonMethods
        # Pass a tag string, returns taggables that match the tag string.
        # 
        # Options:
        #   :match - Match taggables matching :all or :any of the tags, defaults to :any
        def find_tagged_with(tags, options = {})
          options.assert_valid_keys([:match])
          
          tags = Tag.parse(tags)
          return [] if tags.empty?
          
          group = "#{table_name}_taggings.taggable_id HAVING COUNT(#{table_name}_taggings.taggable_id) = #{tags.size}" if options[:match] == :all
          
          find(:all, 
            { 
              :select =>  "DISTINCT #{table_name}.*",
              :joins  =>  "LEFT OUTER JOIN taggings #{table_name}_taggings ON #{table_name}_taggings.taggable_id = #{table_name}.#{primary_key} AND #{table_name}_taggings.taggable_type = '#{name}' " +
                          "LEFT OUTER JOIN tags #{table_name}_tags ON #{table_name}_tags.id = #{table_name}_taggings.tag_id",
              :conditions => sanitize_sql(["#{table_name}_tags.name IN (?)", tags]),
              :group  =>  group
            })
        end
      end
      
      module InstanceMethods
        def tag_list=(new_tag_list)
          unless tag_list == new_tag_list
            @new_tag_list = new_tag_list
          end
        end
        
        def tag_list
          tags.collect { |tag| tag.name.include?(" ") ? %("#{tag.name}") : tag.name }.join(" ")
        end
        
        def update_tags
          if @new_tag_list
            Tag.transaction do
              taggings.destroy_all
            
              Tag.parse(@new_tag_list).each do |name|
                Tag.find_or_create_by_name(name).tag(self)
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