Gem::Specification.new do |s|
  s.name = 'acts_as_taggable_redux'
  s.version = '0.0.1'
  s.date = '2008-12-06'

  s.summary = 'Allows for user owned tags to be added to multiple classes, and makes tags easier to work with.'
  s.description = 'Allows for user owned tags to be added to multiple classes, and makes tags easier to work with.'

  s.authors = ['Wesley Beary']
  s.email = 'monki@geemus.com'
  s.homepage = 'http://github.com/monki/acts_as_taggable_redux'

  s.has_rdoc = false
  s.files = [
    'generators/acts_as_taggable_tables/templates/migration.rb',
    'generators/acts_as_taggable_tables/acts_as_taggable_tables_generator.rb',
    'generators/acts_as_taggable_stylesheet/templates/acts_as_taggable_stylesheet.css',
    'generators/acts_as_taggable_stylesheet/acts_as_taggable_stylesheet_generator.rb',
    'init.rb',
    'lib/acts_as_taggable.rb',
    'lib/acts_as_tagger.rb',
    'lib/acts_as_taggable_helper.rb',
    'lib/acts_as_taggable_redux.rb',
    'lib/tag.rb',
    'lib/tagging.rb',
    'MIT-LICENSE',
    'Rakefile',
    'README',
    'tasks/acts_as_taggable_tasks.rake'
    'test/tagging_test.rb',
    'test/debug.log',
    'test/test_helper.rb',
    'test/fixtures/users.yml',
    'test/fixtures/tags.yml',
    'test/fixtures/things.yml',
    'test/fixtures/thing.rb',
    'test/fixtures/taggings.yml',
    'test/fixtures/user.rb',
    'test/acts_as_taggable_test.rb',
    'test/tag_test.rb',
    'test/database.yml',
    'test/schema.rb'
  ]
end
