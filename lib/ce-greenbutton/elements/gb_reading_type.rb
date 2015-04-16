# Copyright (C) 2015 TopCoder Inc., All Rights Reserved.

require 'sax-machine'

module GreenButton
  module Parser
    # a sax-machine mapping for the espi:ReadingType structure
    #
    # For example:
    #   reading_type = GbReadingType.parse(open(reading_type.xml))
    #
    #
    # Author: ahmed.seddiq
    # Version: 1.0
    class GbReadingType
      include SAXMachine

      # Elements with "espi" namespace
      element :'espi:commodity', class: Integer, as: :commodity
      element :'espi:currency', class: Integer, as: :currency
      element :'espi:uom', class: Integer, as: :uom
      element :'espi:powerOfTenMultiplier', class: Integer, as: :power_of_ten_multiplier
  
      # Elements without namespace
      element :commodity, class: Integer, as: :commodity
      element :currency, class: Integer, as: :currency
      element :uom, class: Integer, as: :uom
      element :powerOfTenMultiplier, class: Integer, as: :power_of_ten_multiplier
    end
  end
end
