module UserLocator
  def self.active_record_geocoder(options={})
    customers, distance = options.values_at(:customers, :distance)
    raise ArgumentError unless [customers, distance].all?
    customers.each do |customer|
      Customer.create(customer) unless Customer.exists?(user_id: customer['user_id'])
    end
    # raise an error unless all the companies were created from JSON
    # i.e. expecting the "customers" passed to this method to be every customer added to the db
    raise StandardError unless Customer.count == customers.count
    results = Customer.near(["53.3381985","-6.2592576"], distance) # use the Geocoder gem to distance-filter
    return results
  end
end