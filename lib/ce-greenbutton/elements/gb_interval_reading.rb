# Copyright (C) 2015 TopCoder Inc., All Rights Reserved.

require 'sax-machine'
require 'ce-greenbutton/elements/gb_interval'

module GreenButton
  module Parser
    # a sax-machine mapping for the espi:IntervalReading structure
    #
    # For example:
    #   interval_reading = GbIntervalReading.parse(open(interval_reading.xml))
    #
    #
    # Author: ahmed.seddiq
    # Version: 1.0
    class GbIntervalReading < GbInterval
      include SAXMachine

      # Elements with "espi" namespace
      element :'espi:value', class: Integer, as: :value
      element :'espi:cost', class: Integer, as: :cost
  
      # Elements without namespace
      element :value, class: Integer, as: :value
      element :cost, class: Integer, as: :cost
    end
  end
end
