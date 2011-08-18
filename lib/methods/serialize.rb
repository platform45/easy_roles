module EasyRoles
  class Serialize
    def initialize(base, column_name, options)
      base.serialize column_name.to_sym, Array

      ActiveSupport::Deprecation.silence do
        base.respond_to?(:before_validation_on_create) ? base.before_validation_on_create(:make_default_roles) : base.before_validation(:make_default_roles, :on => :create)
      end
      
      base.send :define_method, :has_role? do |role|
        self[column_name.to_sym].include?(role)
      end

      base.send :define_method, :add_role do |role|
        clear_roles if self[column_name.to_sym].blank?

        has_role?(role) ? false : self[column_name.to_sym] << role
      end

      base.send :define_method, :add_role! do |role|
        add_role(role)
        self.save!
      end

      base.send :define_method, :remove_role do |role|
        self[column_name.to_sym].delete(role)
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
    end
  end
end
