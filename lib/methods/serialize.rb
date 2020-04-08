# frozen_string_literal: true

module EasyRoles
  # Serialize support
  class Serialize
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity
    def initialize(base, column_name, _options)
      base.serialize column_name.to_sym, Array

      ActiveSupport::Deprecation.silence do
        base.before_validation(:make_default_roles, on: :create)
      end

      base.send :define_method, :has_role? do |role|
        self[column_name.to_sym].include?(role)
      end

      base.send :define_method, :add_role do |role|
        clear_roles if self[column_name.to_sym].blank?
        return false if !@@roles_marker.empty? && role.include?(@@roles_marker)

        has_role?(role) ? false : self[column_name.to_sym] << role
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

      # rubocop:disable Metrics/BlockLength
      base.class_eval do
        # rubocop:disable Style/ClassVars
        @@roles_marker = '!'

        def self.roles_marker
          @@roles_marker
        end

        def self.roles_marker=(value)
          @@roles_marker = value
        end
        # rubocop:enable Style/ClassVars

        scope :with_role, (proc { |r|
          # q =
          where(
            "#{table_name}.#{column_name} LIKE \"%#{@@roles_marker}#{r}#{@@roles_marker}%\""
          )
          # print q.class.inspect
          # q
        })

        scope :without_role, (proc { |r|
          where(
            "#{table_name}.#{column_name} NOT LIKE \"%#{@@roles_marker}#{r}#{@@roles_marker}%\""
          )
        })

        define_method :add_role_markers do
          self[column_name.to_sym].map! { |r| [@@roles_marker, r, @@roles_marker].join }
        end

        define_method :strip_role_markers do
          self[column_name.to_sym].map! { |r| r.gsub(@@roles_marker, '') }
        end

        private :add_role_markers, :strip_role_markers
        before_save :add_role_markers
        after_save :strip_role_markers
        after_rollback :strip_role_markers
        after_find :strip_role_markers
      end
      # rubocop:enable Metrics/BlockLength
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity
  end
end
