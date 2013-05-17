module DynamicModel::ActiveRecordExtension

  def self.included(base) # :nodoc:
    base.extend ClassMethods
  end

  # Be very careful with what is added here as it may conflict with whatever is generated by active record.
  module InstanceMethods

  end

  # This one, only for the class
  module ClassMethods
    def to_param
      "#{self.name_space}/#{self.list_name}"
    end

    def display_name
      self.name.gsub(/^.*::([^:]+)$/, "\\1").titleize
    end

    def domain
      puts name.gsub(/^.*::[^:]+$/, '')
      name.gsub(/::[^:]+$/, '').constantize
    end

    def name_space
      self.name.gsub( /DynamicModel::ManagedDomains::([^:]+)::.*$/, "\\1") .underscore
    end

    def list_name
      self.name.gsub( /^.*::([^:]+)$/, "\\1") .underscore.pluralize
    end

  end

  include InstanceMethods

end