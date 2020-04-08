# frozen_string_literal: true

# rubocop:disable Layout/LineLength
Gem::Specification.new do |s|
  s.name = 'easy_roles'
  s.version = '2.0.1'

  if s.respond_to? :required_rubygems_version=
    s.required_rubygems_version = Gem::Requirement.new('>= 1.2')
  end
  s.authors = ['Platform45']
  s.date = '2011-08-18'
  s.description = 'Easy role authorization in rails'
  s.email = 'ryan@platform45.com'
  s.extra_rdoc_files = ['CHANGELOG.rdoc', 'README.rdoc', 'lib/easy_roles.rb', 'lib/generators/active_record/easy_roles_generator.rb', 'lib/generators/active_record/templates/migration_bitmask.rb', 'lib/generators/active_record/templates/migration_non_bitmask.rb', 'lib/generators/easy_roles/easy_roles_generator.rb', 'lib/generators/templates/README', 'lib/methods/bitmask.rb', 'lib/methods/serialize.rb']
  s.files = ['CHANGELOG.rdoc', 'Gemfile', 'Gemfile.lock', 'README.rdoc', 'Rakefile', 'easy_roles.gemspec', 'init.rb', 'lib/easy_roles.rb', 'lib/generators/active_record/easy_roles_generator.rb', 'lib/generators/active_record/templates/migration_bitmask.rb', 'lib/generators/active_record/templates/migration_non_bitmask.rb', 'lib/generators/easy_roles/easy_roles_generator.rb', 'lib/generators/templates/README', 'lib/methods/bitmask.rb', 'lib/methods/serialize.rb', 'spec/easy_roles_spec.rb', 'spec/spec_helper.rb', 'Manifest']
  s.homepage = 'http://github.com/platform45/easy_roles'
  s.rdoc_options = ['--line-numbers', '--inline-source', '--title', 'Easy_roles', '--main', 'README.rdoc']
  s.require_paths = ['lib']
  s.rubyforge_project = 'easy_roles'
  s.rubygems_version = '1.8.8'
  s.summary = 'Easy role authorization in rails'

  if s.respond_to? :specification_version
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0')
      s.add_runtime_dependency('activesupport', ['>= 0'])
      s.add_development_dependency('activerecord', ['>= 0'])
      s.add_development_dependency('rspec', ['>= 0'])
      s.add_development_dependency('rubocop', ['>= 0'])
      s.add_development_dependency('sqlite3', ['>= 0'])
    else
      s.add_dependency('activerecord', ['>= 0'])
      s.add_dependency('activesupport', ['>= 0'])
      s.add_dependency('rspec', ['>= 0'])
      s.add_dependency('sqlite3', ['>= 0'])
    end
  else
    s.add_dependency('activesupport', ['>= 0'])
    s.add_dependency('rspec', ['>= 0'])
    s.add_dependency('rspec', ['>= 0'])
    s.add_dependency('sqlite3', ['>= 0'])
  end
end
# rubocop:enable Layout/LineLength
