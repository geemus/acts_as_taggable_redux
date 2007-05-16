require 'acts_as_taggable'
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Taggable)
ActionView::Base.send(:include, ActsAsTaggableHelper)

require File.dirname(__FILE__) + '/lib/tagging'
require File.dirname(__FILE__) + '/lib/tag'