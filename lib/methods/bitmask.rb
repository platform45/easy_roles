module EasyRoles
  class Bitmask
    def initialize(base, column_name, options)
      base.send :define_method, :_roles= do |roles|
        states = base.const_get(column_name.upcase.to_sym)

        self[column_name.to_sym] = (roles & states).map { |r| 2**states.index(r) }.sum
      end

      base.send :define_method, :_roles do
        states = base.const_get(column_name.upcase.to_sym)

        states.reject { |r| ((self[column_name.to_sym] || 0) & 2**states.index(r)).zero? }
      end
      
      base.send :define_method, :has_role? do |role|
        self._roles.inspect

        self._roles.include?(role)
      end

      base.send :define_method, :add_role do |role|
        new_roles = self._roles.push(role).uniq
        self._roles = new_roles
      end

      base.send :define_method, :add_role! do |role|
        add_role(role)
        self.save!
      end

      base.send :define_method, :remove_role do |role|
        new_roles = self._roles
        new_roles.delete(role)

        self._roles = new_roles
      end

      base.send :define_method, :remove_role! do |role|
        remove_role(role)
        self.save!
      end

      base.send :define_method, :clear_roles do
        self[column_name.to_sym] = 0
      end

      base.send :define_method, :clear_roles! do 
        self.clear_roles

        self.save!
      end
    end
  end
end
