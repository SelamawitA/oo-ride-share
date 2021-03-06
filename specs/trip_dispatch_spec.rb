require_relative 'spec_helper'
require 'time'
require 'pry'

describe "TripDispatcher class" do
  describe "Initializer" do
    it "is an instance of TripDispatcher" do
      dispatcher = RideShare::TripDispatcher.new
      dispatcher.must_be_kind_of RideShare::TripDispatcher
    end


    it "establishes the base data structures when instantiated" do
      dispatcher = RideShare::TripDispatcher.new
      [:trips, :passengers, :drivers].each do |prop|
        dispatcher.must_respond_to prop
      end

      dispatcher.trips.must_be_kind_of Array
      dispatcher.passengers.must_be_kind_of Array
      dispatcher.drivers.must_be_kind_of Array
    end

  end
  describe "request_trip" do
    it "can return a new requested trip" do
      dispatcher = RideShare::TripDispatcher.new
      temp_ride_status = :PENDING

      new_trip = dispatcher.request_trip(1)
      new_trip.must_be_instance_of RideShare::Trip
      new_trip.id.must_equal 1
      new_trip.passenger.must_be_instance_of RideShare::Passenger
      new_trip.driver.must_be_instance_of RideShare::Driver
      new_trip.start_time.must_be_instance_of Time
      new_trip.end_time.must_equal temp_ride_status
      new_trip.cost.must_equal 0
      new_trip.rating.must_equal temp_ride_status
    end

    it "trip list for driver will be updated after a request" do
      original_drivers_length = 8
      dispatcher = RideShare::TripDispatcher.new
      new_trip = dispatcher.request_trip(1)
      new_trip.driver.trips.length.must_equal original_drivers_length+1
    end

    it "will return nil when no available driver cannot be found" do
      dispatcher = RideShare::TripDispatcher.new
      dispatcher.drivers.each do |driver|
        driver.status = :UNAVAILABLE
      end
      dispatcher.request_trip(1).must_be_nil
    end
  end

  describe "assign_by_driver_status" do
    it "can ensure the first driver assigned will be a person who has never had a passenger" do
      dispatcher = RideShare::TripDispatcher.new
      a_single_trip = 1

      new_trip_for_longest_wait = dispatcher.assign_by_driver_status(1)
      length_of_longest_wait = new_trip_for_longest_wait.driver.trips.length

      dispatcher.drivers.each do |a_driver|
        if a_driver.status == :AVAILABLE && a_driver.name != new_trip_for_longest_wait.driver.name
          a_driver.trips.length.must_be :>, length_of_longest_wait - a_single_trip
        end
      end

      length_of_longest_wait.must_equal 1
    end

    it "can send the driver who has waited the longest to a passenger first (excluding new drivers from test)" do
      first_driver_end_time = Time.parse('2017-02-19 18:39:00 +0000')
      last_driver_end_time = Time.parse('2017-01-28 13:01:00 +0000')

      dispatcher = RideShare::TripDispatcher.new
      all_available_drivers = dispatcher.drivers.find_all{|driver|driver.status == :AVAILABLE}
      passenger = 1
      (all_available_drivers.length-2).times do
        dispatcher.assign_by_driver_status(passenger)
        passenger+=1
      end
      reduced_available_drivers = dispatcher.drivers.find_all{|driver|driver.status == :AVAILABLE}
      new_trip = dispatcher.assign_by_driver_status(46)
      new_trip.driver.trips[-2].end_time.must_equal last_driver_end_time
    end

    it "Will return nil with no available drivers" do
      dispatcher = RideShare::TripDispatcher.new
      all_available_drivers = dispatcher.drivers.find_all{|driver|driver.status == :AVAILABLE}
      passenger = 1
      all_available_drivers.length.times do
        dispatcher.assign_by_driver_status(passenger)
        passenger+=1
      end
      dispatcher.assign_by_driver_status(55).must_be_nil
    end
  end


  describe "find_driver method" do
    before do
      @dispatcher = RideShare::TripDispatcher.new
    end

    it "throws an argument error for a bad ID" do
      proc{ @dispatcher.find_driver(0) }.must_raise ArgumentError
    end

    it "finds a driver instance" do
      driver = @dispatcher.find_driver(2)
      driver.must_be_kind_of RideShare::Driver
    end
  end

  describe "find_passenger method" do
    before do
      @dispatcher = RideShare::TripDispatcher.new
    end

    it "throws an argument error for a bad ID" do
      proc{ @dispatcher.find_passenger(0) }.must_raise ArgumentError
    end

    it "finds a passenger instance" do
      passenger = @dispatcher.find_passenger(2)
      passenger.must_be_kind_of RideShare::Passenger
    end

  end

  describe "loader methods" do
    it "accurately loads driver information into drivers array" do
      dispatcher = RideShare::TripDispatcher.new

      first_driver = dispatcher.drivers.first
      last_driver = dispatcher.drivers.last

      first_driver.name.must_equal "Bernardo Prosacco"
      first_driver.id.must_equal 1
      first_driver.status.must_equal :UNAVAILABLE
      last_driver.name.must_equal "Minnie Dach"
      last_driver.id.must_equal 100
      last_driver.status.must_equal :AVAILABLE
    end

    it "accurately loads passenger information into passengers array" do
      dispatcher = RideShare::TripDispatcher.new

      first_passenger = dispatcher.passengers.first
      last_passenger = dispatcher.passengers.last

      first_passenger.name.must_equal "Nina Hintz Sr."
      first_passenger.id.must_equal 1
      last_passenger.name.must_equal "Miss Isom Gleason"
      last_passenger.id.must_equal 300
    end

    it "accurately loads trip info and associates trips with drivers and passengers" do
      dispatcher = RideShare::TripDispatcher.new

      trip = dispatcher.trips.first
      driver = trip.driver
      passenger = trip.passenger
      
      driver.must_be_instance_of RideShare::Driver
      driver.trips.must_include trip
      passenger.must_be_instance_of RideShare::Passenger
      passenger.trips.must_include trip
    end

    it "must be an instant of the Time class for start_time as read in by the CSV" do
      dispatcher = RideShare::TripDispatcher.new
      dispatcher.trips.each do |a_trip|
        a_trip.start_time.must_be_instance_of Time
      end
    end

    it "must be an instant of the Time class for end_time as read in by the CSV" do
      dispatcher = RideShare::TripDispatcher.new
      dispatcher.trips.each do |a_trip|
        a_trip.end_time.must_be_instance_of Time
      end
    end
  end

end
