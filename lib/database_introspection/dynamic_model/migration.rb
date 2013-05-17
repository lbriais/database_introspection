class DynamicModel::Migration < ActiveRecord::Migration
  def self.create_with(name, &block)
    create_table name.to_sym do |t|
      block.call(t) if block_given?
      begin
        t.timestamps
      rescue
        puts "Cannot create timestamps... Probably already created."
      end
    end
  end
end