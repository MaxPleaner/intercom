require 'active_record'
require 'geocoder'

module UserLocator
  class CreateCustomers < ActiveRecord::Migration
    def change
      create_table :customers do |t|
        t.string :name
        t.integer :user_id
        t.float :distance, null: true
        t.float :latitude
        t.float :longitude
      end
    end
  end
  class Customer < ActiveRecord::Base
    extend Geocoder::Model::ActiveRecord
    reverse_geocoded_by :latitude, :longitude
  end
  def self.active_record_geocoder(options={})
    customers, distance = options.values_at(:customers, :distance)
    raise ArgumentError unless [customers, distance].all?
    `rm ./lib/database.sqlite` rescue nil # start anew every time
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database  => "./lib/database.sqlite" 
    )
    CreateCustomers.migrate(:up)
    customers.each do |customer|
      Customer.create(customer)
    end
    # raise an error unless all the companies were created from JSON
    raise StandardError unless Customer.count == customers.count
    results = Customer.near(["53.3381985","-6.2592576"], distance)
    return results
  end
end