require 'csv'
require_relative 'trip'

module RideShare
  class Driver
    DRIVER_FEE = 1.65
    PERCENT_ALLOCATED_TO_DRIVER = 0.8
    SECONDS_TO_HOUR_RATE = 3600
    attr_reader :id, :name, :vehicle_id, :status, :trips
    attr_accessor :status

    def initialize(input)
      if input[:id] == nil || input[:id] <= 0
        raise ArgumentError.new("ID cannot be blank or less than zero. (got #{input[:id]})")
      end
      if input[:vin] == nil || input[:vin].length != 17
        raise ArgumentError.new("VIN cannot be less than 17 characters.  (got #{input[:vin]})")
      end
      @id = input[:id]
      @name = input[:name]
      @vehicle_id = input[:vin]
      @status = input[:status] == nil ? :AVAILABLE : input[:status]
      @trips = input[:trips] == nil ? [] : input[:trips]
    end

    def average_rating
      total_ratings = 0
      @trips.each do |trip|
        total_ratings += trip.rating
      end
      if trips.length == 0
        average = 0
      else
        average = (total_ratings.to_f) / trips.length
      end
      return average
    end

    def add_trip(trip)
      if trip.class != Trip
        raise ArgumentError.new("Can only add trip instance to trip collection")
      end
      @trips << trip
    end

    def total_revenue
      total_revenue = 0
      @trips.each do |a_trip|
        total_revenue += (a_trip.cost - DRIVER_FEE)*PERCENT_ALLOCATED_TO_DRIVER
      end
      return total_revenue
    end

    def total_revenue_per_hour
      total_time = 0
      @trips.each do |a_trip|
        total_time += a_trip.trip_in_seconds
      end
      if total_time == 0
        rev_per_hour = 0
      else
        total_time = (total_time.to_f/SECONDS_TO_HOUR_RATE)
        rev_per_hour = total_revenue/(total_time)
      end
      return rev_per_hour
    end
  end
end
