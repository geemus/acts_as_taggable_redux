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

  # Grab a distinct list of tags only for a particular type of taggable. 
  # For example, if you had a taggable Foo, you could get all tags used on Foo via:
  #
  #  Tag.with_type_scope('Foo') { Tag.find(:all) }
  #
  # If no parameter is given, the scope does not take effect.
  #
  # pass in a user id to have it scope by user_id as well

  def self.with_type_scope(taggable_type, user = nil)
    if taggable_type
      conditions = sanitize_sql(["taggable_type = ?", taggable_type])
      conditions += sanitize_sql([" AND #{Tagging.table_name}.user_id = ?", user.id]) if user
      with_scope(:find => {:select => "distinct #{Tag.table_name}.*", :joins => "left outer join #{Tagging.table_name} on #{Tagging.table_name}.tag_id = #{Tag.table_name}.id", :conditions => conditions, :group => "name"}) { yield }
    else
      yield
    end
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
