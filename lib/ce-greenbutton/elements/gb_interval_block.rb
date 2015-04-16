# Copyright (C) 2015 TopCoder Inc., All Rights Reserved.

require 'sax-machine'
require 'ce-greenbutton/elements/gb_interval'
require 'ce-greenbutton/elements/gb_interval_reading'

module GreenButton
  module Parser
    # a sax-machine mapping for the espi:IntervalBlock structure
    #
    # For example:
    #   interval_block = GbIntervalBlock.parse(open(interval_block.xml))
    #
    #
    # Author: ahmed.seddiq
    # Version: 1.0
    class GbIntervalBlock
      include SAXMachine

      # Elements with "espi" namespace
      element :'espi:interval', class: GbInterval, as: :interval
      elements :'espi:IntervalReading', class: GbIntervalReading, as: :readings
  
      # Elements without namespace
      element :interval, class: GbInterval, as: :interval
      elements :IntervalReading, class: GbIntervalReading, as: :readings
    end

  end
end
