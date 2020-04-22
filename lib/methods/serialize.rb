# frozen_string_literal: true

module EasyRoles
  # Serialize support
  class Serialize
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity
    def initialize(base, column_name, _options)
      base.serialize column_name.to_sym, Array
      base.before_validation(:make_default_roles, on: :create)
      base.send :define_method, :has_role? do |role|
        self[column_name.to_sym].include?(role)
      end

      base.send :define_method, :add_role do |*roles|
        clear_roles if self[column_name.to_sym].blank?

        roles.each do |role|
          return false if !roles_marker.empty? && role.include?(roles_marker)
        end

        roles.each do |role|
          next if has_role?(role)

          self[column_name.to_sym] << role
        end

        self[column_name.to_sym]
      end

      base.send :define_method, :add_role! do |role|
        return false unless add_role(role)

        save!
      end

      base.send :define_method, :remove_role do |role|
        self[column_name.to_sym].delete(role)
      end

      base.send :define_method, :remove_role! do |role|
        remove_role(role)
        save!
      end

      base.send :define_method, :clear_roles do
        self[column_name.to_sym] = []
      end

      base.send :define_method, :make_default_roles do
        clear_roles if self[column_name.to_sym].blank?
      end

      base.send :private, :make_default_roles

      # Scopes:
      # ---------
      # For security, wrapping markers must be included in the LIKE search,
      # otherwise a user with role 'administrator' would erroneously be included
      # in `User.with_scope('admin')`.
      #
      # Rails uses YAML for serialization, so the markers are newlines.
      # Unfortunately, sqlite can't match newlines reliably, and it doesn't
      # natively support REGEXP. Therefore, hooks are currently being used to
      # wrap roles in '!' markers when talking to the database. This is hacky,
      # but unavoidable. The implication is that, for security, it must be
      # actively enforced that role names cannot include the '!' character.
      #
      # An alternative would be to use JSON instead of YAML to serialize the
      # data, but I've wrestled countless SerializationTypeMismatch errors
      # trying to accomplish this, in vain. The real problem, of course, is even
      # trying to query serialized data. I'm unsure how well this would work in
      # different ruby versions or implementations, which may handle object
      # dumping differently. Bitmasking seems to be a more reliable strategy.

      base.class_eval do
        alias_method :add_roles, :add_role
        alias_method :add_roles!, :add_role

        cattr_accessor :roles_marker
        cattr_accessor :column

        self.roles_marker = '!'
        self.column = "#{table_name}.#{column_name}"

        scope :with_role, (proc { |r|
          where("#{column} LIKE \"%#{roles_marker}#{r}#{roles_marker}%\"")
        })

        scope :without_role, (proc { |r|
          where("#{column} NOT LIKE \"%#{roles_marker}#{r}#{roles_marker}%\" OR #{column} IS NULL")
        })

        define_method :add_role_markers do
          self[column_name.to_sym].map! { |r| [roles_marker, r, roles_marker].join }
        end

        define_method :strip_role_markers do
          self[column_name.to_sym].map! { |r| r.gsub(roles_marker, '') }
        end

        private :add_role_markers, :strip_role_markers
        before_save :add_role_markers
        after_save :strip_role_markers
        after_rollback :strip_role_markers
        after_find :strip_role_markers
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity
  end
end
