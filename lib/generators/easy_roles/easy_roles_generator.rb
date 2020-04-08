# frozen_string_literal: true

module EasyRoles
  module Generators
    # Generator class to add EasyRoles to an ActiveRecord model.
    class EasyRolesGenerator < Rails::Generators::NamedBase
      namespace 'easy_roles'

      argument :role_col, type: :string, required: false, default: 'roles', banner: 'role column'

      class_option :use_bitmask_method, type: :boolean, required: false, default: false,
                                        desc: 'Setup migration for Bitmask method'

      # rubocop:disable Layout/LineLength
      desc 'Create ActiveRecord migration for easy_roles on NAME model using [ROLE] column -- defaults to \'roles\''
      # rubocop:enable Layout/LineLength

      source_root File.expand_path('../templates', __dir__)

      hook_for :orm

      def show_readme
        readme 'README' if behavior == :invoke
      end
    end
  end
end
