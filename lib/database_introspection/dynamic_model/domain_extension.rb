require 'active_record'

module DynamicModel::DomainExtension

  def model_classes
    self.constants.map {|sym| "#{self.name}::#{sym.to_s}".constantize}
  end

  def table_names
    ActiveRecord::Base.connection.tables.grep(/^#{prefix}_/)
  end

  def scoped_table_names
    table_names.map{|table_name| table_name.gsub /^#{prefix}_/, ''}
  end

  def prefix
    DynamicModel::ManagedDomains.to_hash[self]
  end

  def add_table(scoped_table_name, &block)
    DynamicModel.add_table scoped_table_name, table_prefix: prefix, &block
  end

  def alter_table(scoped_table_name, &block)
    DynamicModel.alter_table scoped_table_name, table_prefix: prefix, &block
  end

  def model_class(scoped_table_name)
    Hash[scoped_table_names.zip model_classes][scoped_table_name]
  end
end
