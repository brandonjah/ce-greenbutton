# Copyright (C) 2015 TopCoder Inc., All Rights Reserved.
require 'ce-greenbutton/utils'

# Represents an IntervalBlock structure.
#
# Author TCSASSEMBLER
# Version 1.0
class GbData
  include Utils::Hash

  # A reference to the owner GbDataDescription
  attr_accessor :gb_data_description

  # Represents the start time (local) value from the IntervalBlock -> Interval
  # structure
  attr_accessor :time_start

  # Represents the duration value from the IntervalBlock -> Interval structure
  attr_accessor :time_duration

  # An array of GbDataReading
  attr_accessor :interval_readings

  # Returns the parsed elements as a hash with key equals the property name and
  # value equals the parsed value.
  def _parse
    to_hash
  end

end