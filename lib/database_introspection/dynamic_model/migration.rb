require 'active_record'
class DynamicModel::Migration < ActiveRecord::Migration
  def self.create_for(name, &block)
    create_table name.to_sym do |t|
      block.call(t) if block_given?
      begin
        t.timestamps
      rescue
        puts "Cannot create timestamps... Probably already created."
      end
    end
  end

  def self.update_for(name, &block)
    change_table name.to_sym do |t|
      block.call(t) if block_given?
    end
  end

end
