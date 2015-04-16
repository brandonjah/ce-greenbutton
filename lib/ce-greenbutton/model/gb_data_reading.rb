# Copyright (C) 2015 TopCoder Inc., All Rights Reserved.

# Represents an IntervalReading structure.
#
# Author ahmed.seddiq
# Version 1.0
class GbDataReading

  # Represents the start time (local) value from the IntervalReading ->
  # timePeriod structure
  attr_accessor :time_start

  # Represents the duration value from the IntervalReading -> timePeriod
  # structure
  attr_accessor :time_duration

  # Represents the value element in the IntervalReading structure
  attr_accessor :value

  # Represents the cost element in the IntervalReading structure
  attr_accessor :cost

end