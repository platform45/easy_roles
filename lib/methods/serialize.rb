module EasyRoles
  class Serialize

    def initialize(base, column_name, options)
      base.serialize column_name.to_sym, Array

      ActiveSupport::Deprecation.silence do
        base.before_validation(:make_default_roles, on: :create)
      end

      base.send :define_method, :has_role? do |role|
        self[column_name.to_sym].include?(role.to_s)
      end

      base.send :define_method, :add_role do |role|
        clear_roles if self[column_name.to_sym].blank?

        marker = base::ROLES_MARKER
        return false if (!marker.empty? && role.to_s.include?(marker))

        has_role?(role.to_s) ? false : self[column_name.to_sym] << role.to_s
      end

      base.send :define_method, :add_role! do |role|
        if add_role(role)
          self.save!
        else
          return false
        end
      end

      base.send :define_method, :remove_role do |role|
        self[column_name.to_sym].delete(role.to_s)
      end

      base.send :define_method, :remove_role! do |role|
        remove_role(role)
        self.save!
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
      # For security, wrapping markers must be included in the LIKE search, otherwise a user with
      # role 'administrator' would erroneously be included in `User.with_scope('admin')`.
      #
      # Rails uses YAML for serialization, so the markers are newlines. Unfortunately, sqlite can't match
      # newlines reliably, and it doesn't natively support REGEXP. Therefore, hooks are currently being used
      # to wrap roles in '!' markers when talking to the database. This is hacky, but unavoidable.
      # The implication is that, for security, it must be actively enforced that role names cannot include
      # the '!' character.
      #
      # An alternative would be to use JSON instead of YAML to serialize the data, but I've wrestled
      # countless SerializationTypeMismatch errors trying to accomplish this, in vain. The real problem, of course,
      # is even trying to query serialized data. I'm unsure how well this would work in different ruby versions or
      # implementations, which may handle object dumping differently. Bitmasking seems to be a more reliable strategy.

      base.class_eval do
        const_set :ROLES_MARKER, '!'
        scope :with_role, proc { |r|
          # In PostgreSQL using double quote for string fails
          query = "#{self.table_name}.#{column_name} LIKE " + "'%#{base::ROLES_MARKER}#{r.to_s}#{base::ROLES_MARKER}%'"
          where(query)
        }

        define_method :add_role_markers do
          self[column_name.to_sym].map! { |r| [base::ROLES_MARKER,r,base::ROLES_MARKER].join }
        end

        define_method :strip_role_markers do
          self[column_name.to_sym].map! { |r| r.gsub(base::ROLES_MARKER,'') }
        end

        private :add_role_markers, :strip_role_markers
        before_save :add_role_markers
        after_save :strip_role_markers
        after_rollback :strip_role_markers
        after_find :strip_role_markers
      end

    end
  end
end
