# Copyright (C) 2015 TopCoder Inc., All Rights Reserved.
require 'ce-greenbutton/utils'

# Represents common data for a UsagePoint
#
# Author TCSASSEMBLER
# Version 1.0
class GbDataDescription
  include Utils::Hash

  # Represents the custodian value in the ApplicationInformation structure.
  attr_accessor :custodian

  # Represents the access_token used to retrieve the GreenButton data.
  attr_accessor :user_id

  # Represents the commodity value of the corresponding ReadingType structure.
  attr_accessor :commodity

  # Represents the currency value of the corresponding ReadingType structure.
  attr_accessor :currency

  # Represents the "uom" value of the corresponding ReadingType structure.
  attr_accessor :unit_of_measure

  # Represents the "powerOfTenMultiplier" value of the corresponding
  # ReadingType structure.
  attr_accessor :power_of_ten_multiplier

  # Represents the last updated date/time
  attr_accessor :updated

  # An array of GbData
  attr_accessor :gb_data_array

  # Returns the parsed elements as a hash with key equals the property name and
  # value equals the parsed value.
  def _parse
    to_hash
  end
end