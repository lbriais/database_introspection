require 'active_record'

class DynamicModel::TablesAnalyser

  attr_reader :domain, :base_class, :klasses_analysed

  def initialize(domain, base_class = ActiveRecord::Base)
    @domain = domain
    @base_class = base_class
    define_domain_module
    @klasses_analysed = []
  end

  def scan_database
    # Introspect database tables and creates ActiveRecord descendants in the name space module
    @domain_module.table_names.map do |table_name|
      inject_class table_name
    end
    @domain_module.model_classes
  end

  private


  def inject_class(table_name)
    short_model_name = table_name.gsub(/#{@domain_module.prefix}_/, '').singularize.camelize
    klass = nil
    if @domain_module.constants.include? short_model_name.to_sym
      klass = @domain_module.const_get short_model_name
      puts "Found #{klass.name} that already handles #{table_name}"
      klass.reset_column_information
    else
      klass = @domain_module.const_set short_model_name, Class.new(@base_class)
      puts "Created #{klass.name} to handle #{table_name}"

    end
    # Adds some class methods
    klass.send :include, DynamicModel::ActiveRecordExtension
    #end
    # Disables STI
    klass.inheritance_column = nil

    # Maps the class to the correct table
    klass.table_name = table_name
    # Adds attributes accessible for mass assign
    klass.attr_accessible *(klass.attribute_names - [klass.primary_key])
  end

  def define_domain_module
    domain_name = @domain.singularize.camelize
    @domain_module = nil
    if DynamicModel::ManagedDomains.constants.include? domain_name.to_sym
      @domain_module = DynamicModel::ManagedDomains.const_get domain_name
    else
      @domain_module = DynamicModel::ManagedDomains.const_set(domain_name, Module.new)
      @domain_module.extend DynamicModel::DomainExtension
    end
  end


end
