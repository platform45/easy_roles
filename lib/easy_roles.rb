module EasyRoles
  def self.included(base)
    base.extend ClassMethods
    base.send :alias_method_chain, :method_missing, :roles
  end
  
  module ClassMethods
    def easy_roles(name)
      serialize name.to_sym, Array
      before_validation_on_create :make_default_roles
      
      class_eval <<-EOC
        def has_role?(role)
          #{name}.include?(role)
        end

        def add_role(role)
          self.#{name} << role
        end

        def remove_role(role)
          self.#{name}.delete(role)
        end
        
        def clear_roles
          self.#{name} = []
        end
        
        def make_default_roles
          clear_roles if #{name}.nil?
        end
        
        private :make_default_roles
      EOC
    end
  end
  
  def method_missing_with_roles(method_id, *args, &block)
    match = method_id.to_s.match(/^is_(\w+)[?]$/)
    if match && respond_to?('has_role?')
      self.class.send(:define_method, "is_#{match[1]}?") do
        send :has_role?, "#{match[1]}"
      end
      send "is_#{match[1]}?"
    else
      method_missing_without_roles(method_id, *args, &block)
    end
  end
end

class ActiveRecord::Base
  include EasyRoles
end