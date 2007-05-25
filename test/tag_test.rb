require File.dirname(__FILE__) + "/test_helper"

class TagTest < Test::Unit::TestCase
  def test_taggings
    assert_equal [taggings(:bear_animal), taggings(:frog_animal)], tags(:animal).taggings
    assert_not_equal [taggings(:cactus_plant), taggings(:orange_plant)], tags(:animal).taggings
  end
  
  def test_parse_does_not_change_param
    list = 'a b c'
    original = list.dup
    Tag.parse(list)
    assert_equal list, original
  end
  
  def test_parse_blank
    assert_equal [], Tag.parse(nil)
    assert_equal [], Tag.parse('')
  end
  
  def test_parse_single_tag
    assert_equal ['a'], Tag.parse('a')
    assert_equal ['a'], Tag.parse('"a"')
  end
  
  def test_parse_quoted_tags
    assert_equal ['a b', 'c'], Tag.parse('"a b" c')
  end
  
  def test_parse_comma_dilineation
    assert_equal ['a', 'b', 'c'], Tag.parse('a,b,c')
    assert_equal ['a', 'b', 'c'], Tag.parse('a,b,c')
  end
  
  def test_parse_quotes_and_commas
    assert_equal ['a,b', 'c'], Tag.parse('"a,b",c')
  end
  
  def test_parse_removes_whitespace
    assert_equal ['a', 'b', 'c'], Tag.parse('a  b,   c')
  end
  
  def test_parse_removes_duplicates
    assert_equal ['a', 'b', 'c'], Tag.parse('a b a c a b')
  end
  
  def test_tag
    assert !tags(:favorite).tagged.include?(things(:bear))
    tags(:favorite).tag(things(:bear))
    assert tags(:favorite).tagged.include?(things(:bear))
  end
  
  def test_tagged
    assert_equal [things(:bear), things(:frog)], tags(:animal).tagged
    assert_not_equal [things(:bear), things(:frog)], tags(:plant).tagged
  end
  
  def test_equality
    assert_equal tags(:animal), tags(:animal)
    assert_equal Tag.find(1), Tag.find(1)
    assert_equal Tag.new(:name => 'mineral'), Tag.new(:name => 'mineral')
    assert_not_equal Tag.new(:name => 'mineral'), tags(:animal)
  end
  
  def test_to_s
    assert_equal tags(:animal).name, tags(:animal).to_s
  end
end