require File.dirname(__FILE__) + "/test_helper"

class TaggingTest < Test::Unit::TestCase
  def test_taggable
    assert_equal things(:bear), taggings(:bear_animal).taggable
    assert_not_equal things(:frog), taggings(:bear_animal).taggable    
  end
  
  def test_tag
    assert_equal tags(:animal), taggings(:bear_animal).tag
    assert_not_equal tags(:plant), taggings(:bear_animal).tag
  end
end