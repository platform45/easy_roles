# frozen_string_literal: true

require 'rails/generators/active_record'

module ActiveRecord
  module Generators
    # Generator class to add EasyRoles to an ActiveRecord model.
    class EasyRolesGenerator < ActiveRecord::Generators::Base
      argument :role_col, type: :string, required: false, default: 'roles', banner: 'role column'

      class_option :use_bitmask_method, type: :boolean, required: false, default: false,
                                        desc: 'Setup migration for Bitmask method'

      class_option :add_index, type: :boolean, required: false, default: false,
                               desc: 'Add an index to the relevant column'

      desc 'Internal use by easy_roles generator - use that instead'

      source_root File.expand_path('templates', __dir__)

      def copy_easy_roles_migration
        if options.use_bitmask_method
          migration_template 'migration_bitmask.rb.erb',
                             "db/migrate/add_bitmask_roles_to_#{table_name}.rb"
        else
          migration_template 'migration_non_bitmask.rb.erb',
                             "db/migrate/add_easy_roles_to_#{table_name}.rb"
        end
      end
    end
  end
end
