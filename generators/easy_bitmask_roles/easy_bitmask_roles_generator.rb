class EasyBitmaskRolesGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.class_collisions class_name
      m.migration_template 'migration.rb', "db/migrate", :migration_file_name => "add_bitmask_roles_to_#{table_name}"
    end
  end
end