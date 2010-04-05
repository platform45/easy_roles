# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{easy_roles}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Platform45"]
  s.date = %q{2010-04-05}
  s.description = %q{Easy role authorization in rails}
  s.email = %q{ryan@platform45.com}
  s.extra_rdoc_files = ["README.rdoc", "lib/easy_roles.rb"]
  s.files = ["Manifest", "README.rdoc", "Rakefile", "generators/easy_bitmask_roles/USAGE", "generators/easy_bitmask_roles/easy_bitmask_roles_generator.rb", "generators/easy_bitmask_roles/templates/migration.rb", "generators/easy_roles/USAGE", "generators/easy_roles/easy_roles_generator.rb", "generators/easy_roles/templates/migration.rb", "init.rb", "lib/easy_roles.rb", "easy_roles.gemspec"]
  s.homepage = %q{http://github.com/platform45/easy_roles}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Easy_roles", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{easy_roles}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Easy role authorization in rails}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
