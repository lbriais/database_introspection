require 'active_record'

module DynamicModel

  @domain_analyser ||= {}

  # Creates ActiveRecord::Base descendants from the database.
  # ActiveRecord descendant classes are dynamically created from database introspection in their own namespace
  # (DynamicModel::<NameSpace>::) The name of the module NameSpace is derived from table_prefix.
  def self.introspect_database(table_prefix = :user_defined, base_class = ActiveRecord::Base)
    if table_prefix.class == Array
      table_prefix.each {|p| self.introspect_database p, base_class}
      return
    end
    table_prefix = table_prefix.to_s
    analyse_domain table_prefix, base_class
  end

  # Creates a new table with auto numbered id in the database with the name prefix provided
  # by creating a live migration.
  # If block is provided it will behave like create_table method for migrations, allowing
  # to create any other column.
  def self.add_table(scoped_table_name, table_prefix: :user_defined, base_class: ActiveRecord::Base, &block)
    for_action_on_table(scoped_table_name, table_prefix) do |table_prefix, real_table_name|
      Migration::create_for "#{table_prefix}_#{real_table_name}", &block
    end
  ensure
    analyse_domain table_prefix, base_class
  end


  # Modifies a table in the database with the name prefix provided by creating a live migration.
  # If block is provided it will behave like create_table method for migrations, allowing
  # to create any other column.
  def self.alter_table(scoped_table_name, table_prefix: :user_defined, base_class: ActiveRecord::Base, &block)
    raise "Missing block parameter" unless block_given?
    for_action_on_table(scoped_table_name, table_prefix) do |table_prefix, real_table_name|
      Migration::update_for "#{table_prefix}_#{real_table_name}", &block
    end
  ensure
    analyse_domain table_prefix, base_class
  end

  private

  def self.for_action_on_table(scoped_table_name, table_prefix)
    raise "Missing block parameter" unless block_given?
    scoped_table_name = scoped_table_name.to_s
    table_prefix = table_prefix.to_s
    real_table_name = scoped_table_name.underscore.pluralize
    yield table_prefix, real_table_name
  end

  def self.analyse_domain(table_prefix, base_class)
    # Confines Activerecord classes into a module named from table_prefix
    @domain_analyser[table_prefix] ||= DynamicModel::TablesAnalyser.new table_prefix, base_class
    raise "You cannot change the base class for a domain" unless @domain_analyser[table_prefix].base_class == base_class
    klasses = @domain_analyser[table_prefix].scan_database
    relation_analyser = RelationsAnalyser.new klasses
    relation_analyser.run
  end


end
