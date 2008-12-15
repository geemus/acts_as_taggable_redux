module ActiveRecord
  module Acts #:nodoc:
    module Taggable #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_taggable(options = {})
          has_many :taggings, :as => :taggable, :dependent => :destroy, :include => :tag
          has_many :tags, :through => :taggings, :order => 'LOWER(name) asc', :select => "DISTINCT tags.*"

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
          options.assert_valid_keys([:match, :order, :user])

          tags = Tag.parse(tags)
          return [] if tags.empty?

          group = "#{table_name}_taggings.taggable_id HAVING COUNT(#{table_name}_taggings.taggable_id) >= #{tags.size}" if options[:match] == :all
          conditions = sanitize_sql(["#{table_name}_tags.name IN (?)", tags])
          conditions += sanitize_sql([" AND #{table_name}_taggings.user_id = ?", options[:user]]) if options[:user]

          find_parameters = {
            :joins  =>  "LEFT OUTER JOIN #{Tagging.table_name} #{table_name}_taggings ON #{table_name}_taggings.taggable_id = #{table_name}.#{primary_key} AND #{table_name}_taggings.taggable_type = '#{name}' " +
                        "LEFT OUTER JOIN #{Tag.table_name} #{table_name}_tags ON #{table_name}_tags.id = #{table_name}_taggings.tag_id",
            :conditions => conditions,
            :group  =>  group,
            :order => options[:order]
          }

          with_scope(:find => find_parameters) { yield }
        end

        # Pass a tag string, returns taggables that match the tag string for a particular user.
        # 
        # Options:
        #   :match - Match taggables matching :all or :any of the tags, defaults to :any
        def find_tagged_with_by_user(tags, user, options = {})
          options.assert_valid_keys([:match, :order])
          find_tagged_with(tags, {:match => options[:match], :order => options[:order], :user => user})
        end

        # Returns an array of related tags.
        # Related tags are all the other tags that are found on the models tagged with the provided tags.
        #
        # Pass either a tag, string, or an array of strings or tags.
        #
        # Options:
        # :order - SQL Order how to order the tags. Defaults to "count DESC, tags.name".
        # :match - Match taggables matching :all or :any of the tags, defaults to :any
        def find_related_tags(tags, options = {})
          #duplicated work, the tags are parsed twice. I need to elimidate this by making find_tagged_with 
          #accept an array of tags and not just a string
          parsed_tags = Tag.parse(tags)
          related_models = find_tagged_with(tags, :match => options.delete(:match))

          return [] if related_models.blank?

          related_ids = related_models.to_s(:db)

          Tag.find(:all, options.merge({
            :select => "#{Tag.table_name}.*, COUNT(#{Tag.table_name}.id) AS count",
            :joins => "JOIN #{Tagging.table_name} ON #{Tagging.table_name}.taggable_type = '#{base_class.name}'
AND #{Tagging.table_name}.taggable_id IN (#{related_ids})
AND #{Tagging.table_name}.tag_id = #{Tag.table_name}.id",
            :order => options[:order] || "count DESC, #{Tag.table_name}.name",
            :group => "#{Tag.table_name}.id, #{Tag.table_name}.name HAVING #{Tag.table_name}.name NOT IN (#{parsed_tags.map { |n| quote_value(n) }.join(",")})"
          }))
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
            #TODO: make it work if I pass in an int instead of a user object
            tags.find(:all, :conditions => ['"taggings"."user_id" = ?', user.id]).collect { |tag| tag.name.include?(" ") ? %("#{tag.name}") : tag.name }.uniq.join(" ")
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
