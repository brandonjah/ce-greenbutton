# Copyright (C) 2015 TopCoder Inc., All Rights Reserved.
require 'sax-machine'
require 'ce-greenbutton/elements/gb_interval_block'
require 'ce-greenbutton/elements/gb_usage_point'
require 'ce-greenbutton/elements/gb_local_time_parameters'
require 'ce-greenbutton/elements/gb_reading_type'

module GreenButton
  module Parser
    # a sax-machine mapping for the Content structure
    #
    # For example:
    #   content = GbContent.parse(open(content.xml))
    #
    #
    # Author: ahmed.seddiq
    # Version: 1.0
    class GbContent
      include SAXMachine

      # Elements with "espi" namespace
      element :'espi:UsagePoint', class: GbUsagePoint, as: :usage_point
      element :'espi:IntervalBlock', class: GbIntervalBlock, as: :interval_block
      element :'espi:LocalTimeParameters', class: GbLocalTimeParameters, as: :local_time_parameters
      element :'espi:ReadingType', class: GbReadingType, as: :reading_type

      # Elements without namespace
      element :UsagePoint, class: GbUsagePoint, as: :usage_point
      element :IntervalBlock, class: GbIntervalBlock, as: :interval_block
      element :LocalTimeParameters, class: GbLocalTimeParameters, as: :local_time_parameters
      element :ReadingType, class: GbReadingType, as: :reading_type
      
    end
  end
end
