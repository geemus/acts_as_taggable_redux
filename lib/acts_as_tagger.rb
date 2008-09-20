module ActiveRecord
  module Acts #:nodoc:
    module Tagger #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_tagger(options = {})
          has_many :taggings
          has_many :tags, :through => :taggings, :select => "DISTINCT #{Tag.table_name}.*"
          
          extend ActiveRecord::Acts::Tagger::SingletonMethods
          include ActiveRecord::Acts::Tagger::InstanceMethods
        end
      end
      
      module SingletonMethods
      end
      
      module InstanceMethods
      end
    end
  end
end
