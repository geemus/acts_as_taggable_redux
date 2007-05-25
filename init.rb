require 'acts_as_taggable'
require 'acts_as_tagger'
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Taggable)
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Tagger)
ActionView::Base.send(:include, ActsAsTaggableHelper)

require File.dirname(__FILE__) + '/lib/tagging'
require File.dirname(__FILE__) + '/lib/tag'