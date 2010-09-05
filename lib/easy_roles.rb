module EasyRoles
  def self.included(base)
    base.extend ClassMethods
    base.send :alias_method_chain, :method_missing, :roles
  end
  
  module ClassMethods
    def easy_roles(name, options = {})
      
      options[:method] ||= :serialize
      
      if options[:method] == :serialize
        serialize name.to_sym, Array
        respond_to?(:before_validation_on_create) ? before_validation_on_create(:make_default_roles) : before_validation(:make_default_roles, :on => :create)
      
        class_eval <<-EOC
          def has_role?(role)
            #{name}.include?(role)
          end

          def add_role(role)
            clear_roles if self.#{name}.nil?
            has_role?(role) ? false : self.#{name} << role
          end
        
          def add_role!(role)
            add_role(role)
            self.save!
          end

          def remove_role(role)
            self.#{name}.delete(role)
          end
        
          def remove_role!(role)
            remove_role(role)
            self.save!
          end
        
          def clear_roles
            self.#{name} = []
          end
        
          def make_default_roles
            clear_roles if #{name}.nil?
          end
        
          private :make_default_roles
        EOC
      elsif options[:method] == :bitmask
        
        def_name = (name == :roles) ? :easy_roles : :roles
        
        class_eval <<-EOC
          def self.list_roles
            #{name.to_s.upcase}
          end
        
          def #{def_name}=(roles)
            self.#{name} = (roles & #{name.to_s.upcase}).map { |r| 2**#{name.to_s.upcase}.index(r) }.sum
          end

          def #{def_name}
            #{name.to_s.upcase}.reject { |r| ((#{name} || 0) & 2**#{name.to_s.upcase}.index(r)).zero? }
          end
          
          def has_role?(role)
            #{def_name}.include?(role)
          end
          
          def add_role(role)
            new_roles = #{def_name}.push(role).uniq
            self.#{def_name} = new_roles
          end
          
          def add_role!(role)
            add_role(role)
            self.save!
          end
          
          def remove_role(role)
            new_roles = #{def_name}
            new_roles.delete(role)
            self.#{def_name} = new_roles
          end
          
          def remove_role!(role)
            remove_role(role)
            self.save!
          end
          
          def clear_roles
            self.#{name} = 0
          end
          
          def clear_roles!
            self.#{name} = 0
            self.save!
          end
        EOC
      end
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

