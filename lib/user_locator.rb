module UserLocator
  def self.active_record_geocoder(options={})
    customers, distance = options.values_at(:customers, :distance)
    raise ArgumentError unless [customers, distance].all?
    customers.each do |customer|
      Customer.create(customer) unless Customer.exists?(user_id: customer['user_id'])
    end
    # raise an error unless all the companies were created from JSON
    raise StandardError unless Customer.count == customers.count
    results = Customer.near(["53.3381985","-6.2592576"], distance)
    return results
  end
end