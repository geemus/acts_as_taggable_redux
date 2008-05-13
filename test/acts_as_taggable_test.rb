require File.dirname(__FILE__) + "/test_helper"

class ActsAsTaggableTest < Test::Unit::TestCase
  def test_find_tagged_with_any
    assert_equal [things(:bear), things(:frog)].sort_by(&:id), Thing.find_tagged_with("animal")
    assert_equal [things(:bear), things(:frog), things(:cactus)].sort_by(&:id), Thing.find_tagged_with("animal green")
    assert_equal [], Thing.find_tagged_with("fake")
    
    assert_equal [things(:bear), things(:frog)].sort_by(&:id), Thing.find_tagged_with("animal", :match => :any)
    assert_equal [things(:bear), things(:frog), things(:cactus)].sort_by(&:id), Thing.find_tagged_with("animal green", :match => :any)
    assert_equal [], Thing.find_tagged_with("fake", :match => :any)
  end
  
  def test_find_tagged_with_all
    assert_equal [things(:bear), things(:frog)].sort_by(&:id), Thing.find_tagged_with("animal", :match => :all)
    assert_equal [things(:frog)].sort_by(&:id), Thing.find_tagged_with("animal green", :match => :all)    
    assert_equal [], Thing.find_tagged_with("fake", :match => :all)
    assert_equal [], Thing.find_tagged_with("animal plant", :match => :all)
  end
  
  def test_tag_list
    assert_equal things(:bear).tag_list, "animal \"not green\""
    assert_equal things(:frog).tag_list, "animal green"
    assert_not_equal things(:frog).tag_list, "animal \"not green\""
  end
  
  def test_update_tags
    assert_equal things(:bear).tag_list, "animal \"not green\""
    things(:bear).tag_list = 'animal "not green" favorite'
    assert_equal things(:bear).tag_list, "animal \"not green\""
    things(:bear).update_tags
    assert_equal things(:bear).tag_list, "animal favorite \"not green\""
  end
end