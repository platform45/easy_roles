require 'active_support'

module EasyRoles
  extend ActiveSupport::Concern

  included do |base|
    base.send :alias_method, :method_missing_without_roles, :method_missing
    base.send :alias_method, :method_missing, :method_missing_with_roles

    base.send :alias_method, :respond_to_without_roles?, :respond_to?
    base.send :alias_method, :respond_to?, :respond_to_with_roles?
  end

  ALLOWED_METHODS = [:serialize, :bitmask]

  ALLOWED_METHODS.each do |method|
    autoload method.to_s.capitalize.to_sym, "methods/#{method}"
  end

  module ClassMethods
    def easy_roles(name, options = {method: :serialize})
      begin
        raise NameError unless ALLOWED_METHODS.include? options[:method]
      rescue NameError
        puts "[Easy Roles] Storage method does not exist reverting to Serialize"
        options[:method] = :serialize
      end
      "EasyRoles::#{options[:method].to_s.camelize}".constantize.new(self, name, options)
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
