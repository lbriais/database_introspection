require 'database_introspection/dynamic_model/active_record_extension'
require 'database_introspection/dynamic_model/domain_extension'
require 'database_introspection/dynamic_model/managed_domains'
require 'database_introspection/dynamic_model/tables_analyser'
require 'database_introspection/dynamic_model/relations_analyser'
require 'database_introspection/dynamic_model/migration'

module DynamicModel

  # Creates ActiveRecord::Base descendants from the database.
  # ActiveRecord descendant classes are dynamically created from database introspection in their own namespace
  # (DynamicModel::<NameSpace>::) The name of the module NameSpace is derived from table_prefix.
  def self.introspect_database(table_prefix = :user_defined, base_class = ActiveRecord::Base)
    table_prefix = table_prefix.to_s
    @domain_analyser ||= {}

    # Confines Activerecord classes into a module named from table_prefix
    @domain_analyser[table_prefix] ||= DynamicModel::TablesAnalyser.new table_prefix, base_class
    klasses = @domain_analyser[table_prefix].scan_database
    relation_analyser = RelationsAnalyser.new klasses
    relation_analyser.run
  end

  # Creates a new table with auto numbered id in the database with the name prefix provided
  # by creating a live migration.
  # If block is provided it will behave like create_table method for migrations, allowing
  # to create any other column.
  def self.add_table(scoped_table_name, table_prefix: :user_defined, &block)
    scoped_table_name = scoped_table_name.to_s
    table_prefix = table_prefix.to_s
    real_table_name = scoped_table_name.underscore.pluralize
    Migration::create_with "#{table_prefix}_#{real_table_name}", &block
  end


end
