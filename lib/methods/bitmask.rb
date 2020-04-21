# frozen_string_literal: true

module EasyRoles
  # Bitmask support
  class Bitmask
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def initialize(base, column_name, _options)
      base.send :define_method, :_roles= do |roles|
        states = base.const_get(column_name.upcase.to_sym)
        self[column_name.to_sym] = (roles & states).map { |r| 2**states.index(r) }.sum
      end

      base.send :define_method, :_roles do
        states = base.const_get(column_name.upcase.to_sym)
        masked_integer = self[column_name.to_sym] || 0
        states.reject.with_index { |_r, i| masked_integer[i].zero? }
      end

      base.send :define_method, :has_role? do |role|
        _roles.include?(role)
      end

      base.send :define_method, :add_role do |*roles|
        roles.each do |role|
          self._roles = _roles.push(role).uniq
        end
      end

      base.send :define_method, :add_role! do |*roles|
        roles.each do |role|
          add_role(role)
        end
        save!
      end

      base.send :define_method, :remove_role do |role|
        new_roles = _roles
        new_roles.delete(role)
        self._roles = new_roles
      end

      base.send :define_method, :remove_role! do |role|
        remove_role(role)
        save!
      end

      base.send :define_method, :clear_roles do
        self[column_name.to_sym] = 0
      end

      base.send :define_method, :clear_roles! do
        clear_roles
        save!
      end

      base.class_eval do
        alias_method :add_roles, :add_role
        alias_method :add_roles!, :add_role

        scope :with_role, (proc { |role|
          states = base.const_get(column_name.upcase.to_sym)
          raise ArgumentError unless states.include? role

          role_bit_index = states.index(role)
          valid_mask_integers = (0..2**states.count - 1).select { |i| i[role_bit_index] == 1 }
          where(column_name => valid_mask_integers)
        })
        scope :without_role, (proc { |role|
          states = base.const_get(column_name.upcase.to_sym)
          raise ArgumentError unless states.include? role

          role_bit_index = states.index(role)
          valid_mask_integers = (0..2**states.count - 1).reject { |i| i[role_bit_index] == 1 }
          where(column_name => valid_mask_integers)
        })
      end
    end
    # rubocop:enable Metrics/AbcSize

    # rubocop:enable Metrics/MethodLength
  end
end
