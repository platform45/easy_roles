require 'active_support'

module EasyRoles
  extend ActiveSupport::Concern
  
  included do |base|
    base.send :alias_method_chain, :method_missing, :roles
    base.send :alias_method_chain, :respond_to?, :roles
  end

  ALLOWED_METHODS = [:serialize, :bitmask]
  
  ALLOWED_METHODS.each do |method|
    autoload method.capitalize.to_sym, "methods/#{method}"
  end
  
  module ClassMethods
    def easy_roles(name, options = {})
      options[:method] ||= :serialize
     
      begin
        raise NameError unless ALLOWED_METHODS.include? options[:method]
        
        "EasyRoles::#{options[:method].to_s.camelize}".constantize.new(self, name, options)     
      rescue NameError
        puts "[Easy Roles] Storage method does not exist reverting to Serialize"
        
        EasyRoles::Serialize.new(self, name, options)
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
  
  def respond_to_with_roles?(method_id, include_private = false)
    match = method_id.to_s.match(/^is_(\w+)[?]$/)
    if match && respond_to?('has_role?')
      true
    else
      respond_to_without_roles?(method_id, include_private = false)
    end
  end
end

class ActiveRecord::Base
  include EasyRoles
end

