class Tag < ActiveRecord::Base
  has_many :taggings

  # Parse a text string into an array of tokens for use as tags
  def self.parse(list)
    tag_names = []
    
    return tag_names if list.blank?
    
    # first, pull out the quoted tags
    list.gsub!(/\"(.*?)\"\s*/) { tag_names << $1; "" }
    
    # then, replace all commas with a space
    list.gsub!(/,/, " ")
    
    # then, get whatever is left
    tag_names.concat(list.split(/\s/))
    
    # delete any blank tag names
    tag_names = tag_names.delete_if { |t| t.empty? }
    
    # downcase all tags
    tag_names = tag_names.map! { |t| t.downcase }
    
    # remove duplicates
    tag_names = tag_names.uniq
    
    return tag_names
  end
  
  # Tag a taggable with this tag, optionally add user to add owner to tagging
  def tag(taggable, user_id = nil)
    taggings.create :taggable => taggable, :user_id => user_id
    taggings.reset
    @tagged = nil
  end
  
  # A list of all the objects tagged with this tag
  def tagged
    @tagged ||= taggings.collect(&:taggable)
  end
  
  # Compare tags by name
  def ==(comparison_object)
    super || name == comparison_object.to_s
  end
  
  # Return the tag's name
  def to_s
    name
  end
  
  validates_presence_of :name
end