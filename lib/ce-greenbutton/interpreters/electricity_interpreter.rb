# Copyright (C) 2015 TopCoder Inc., All Rights Reserved.

require 'date'
require 'ce-greenbutton'
require 'ce-greenbutton/model/gb_data_description'
require 'ce-greenbutton/model/gb_data'
require 'ce-greenbutton/model/gb_data_reading'
require 'ce-greenbutton/elements/gb_local_time_parameters'

module GreenButton
  module Interpreters
    # An interpreter for the Electricity GreenButton data. It can be registered
    # to the GreenButton module by calling GreenButton.register_interpreter.
    #
    # The interpreter will be called by the GreenButton module to interpret the
    # electricity GreenButton data (kind = 0)
    #
    # For example:
    #   # This call will bind this interpreter to the GreenButton data of kind=0
    #   GreenButton.register_interpreter(0,:electricity)
    #
    # Author: ahmed.seddiq
    # Version: 1.0
    #
    module ElectricityInterpreter

      # Maps the parsed GbUsagePoint to the equivalent GbDataDescription.
      #
      # usage_point - The parsed GbUsagePoint.
      # feed        - The parsed GbDataFeed. It is used to resolve related
      #                 entries in the usage_point hierarchy.
      #
      # Returns the newly created GbDataDescription instance.
      #
      def self.get_gb_data_description (usage_point, feed)
        gb_data_description = GbDataDescription.new
        gb_data_description.updated = usage_point.updated

        meter_readings = feed.get_related(usage_point, 'MeterReading')
        raise GreenButton::InvalidGbDataError, 'Missing MeterReading data' if meter_readings.nil?

        time_config = feed.get_related(usage_point, 'LocalTimeParameters')
        # raise GreenButton::InvalidGbDataError, 'Missing LocalTimeParameters data' if time_config.nil?

        # get the actual time parameters from the entry.content
        if time_config.nil?
          time_config = GreenButton::Parser::GbLocalTimeParameters::EDT
        else
          time_config = time_config.content.local_time_parameters
        end

        # We can have multiple meter readings per usage point.
        unless meter_readings.is_a? Array
          meter_readings = [meter_readings]
        end
        meter_readings.each do |meter_reading|
          interpret_meter_reading(gb_data_description, meter_reading,
                                  time_config, feed)
        end

        gb_data_description
      end

      # Interprets a single MeterReading structure. It will append all interpreted
      # GbData instances to gb_data_description.gb_data_array.
      #
      # gb_data_description - the GbDataDescription under construction now.
      # meter_reading       - the GbEntry describing the MeterReading structure.
      # time_config         - the GbLocalTimeParameters used to convert time
      #                         values to local.
      # feed                - the parsed GbDataFeed, used to resolve any related
      #                         GbEntries
      #
      # Returns Nothing.
      #
      private
      def self.interpret_meter_reading(gb_data_description, meter_reading,
          time_config, feed)
        reading_type = feed.get_related(meter_reading, 'ReadingType')
        raise GreenButton::InvalidGbDataError, 'Missing ReadingType data' if reading_type.nil?

        reading_type = reading_type.content.reading_type
        gb_data_description.commodity = reading_type.commodity
        gb_data_description.currency = reading_type.currency
        gb_data_description.unit_of_measure = reading_type.uom
        gb_data_description.power_of_ten_multiplier =
            reading_type.power_of_ten_multiplier

        # interval blocks
        interval_blocks = feed.get_related(meter_reading, 'IntervalBlock') || []

        if gb_data_description.gb_data_array.nil?
          gb_data_description.gb_data_array = []
        end
        updated = gb_data_description.updated
        interval_blocks.each do |interval_block|
          updated = interval_block.updated if interval_block.updated > updated
          interval_block = interval_block.content.interval_block
          gb_data = GbData.new
          gb_data.gb_data_description = gb_data_description
          gb_data.time_duration = interval_block.interval.duration
          gb_data.time_start = time_config.local_time(interval_block.interval.start)
          gb_data.interval_readings = []
          interval_block.readings.each do |reading|
            gb_data_reading = GbDataReading.new
            gb_data_reading.time_duration = reading.duration
            gb_data_reading.time_start = time_config.local_time(reading.start)
            gb_data_reading.value = reading.value
            gb_data_reading.cost = reading.cost
            gb_data.interval_readings << gb_data_reading
          end
          gb_data_description.gb_data_array << gb_data
        end
        gb_data_description.updated = time_config.local_time(updated.to_time.to_i)
      end

    end
  end
end
