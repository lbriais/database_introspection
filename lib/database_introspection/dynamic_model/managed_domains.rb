# Namespace for domains
module DynamicModel::ManagedDomains
  def self.domain_prefixes
    constants.map {|c| c.to_s.underscore}
  end

  def self.domain_modules
    constants.map {|c| "#{self.name}::#{c.to_s}".constantize}
  end

  def self.to_hash
    Hash[domain_modules.zip domain_prefixes]
  end

  def self.tables
    self.domain_modules.map {|mod| mod.table_names}.flatten
  end

  def self.domain_module(table_prefix)
    Hash[domain_prefixes.zip domain_modules][table_prefix]
  end

end
