require_relative '../config/connection'
include Connection

class CreateUnpaidRatios < ActiveRecord::Migration

  def self.up
    create_table :unpaid_ratios do |t|
      t.string :operator
      t.string :market
      t.string :area
      t.string :scope
      t.string :use
      t.string :issuing_month
      t.string :reference_month
      t.decimal :revenue
      t.decimal :collected
    end
  end

  def self.down
    drop_table :unpaid_ratios
  end
end



begin
  CreateUnpaidRatios.down
rescue Exception => e
  puts "e: #{e.message}"
ensure
  CreateUnpaidRatios.up
end