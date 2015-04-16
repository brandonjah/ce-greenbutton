# Copyright (C) 2015 TopCoder Inc., All Rights Reserved.

require 'sax-machine'

module GreenButton
  module Parser
    # a sax-machine mapping for the espi:UsagePoint structure
    #
    # For example:
    #   usage_point = GbUsagePoint.parse(open(usage_point.xml))
    #
    #
    # Author: ahmed.seddiq
    # Version: 1.0
    class GbUsagePoint
      include SAXMachine

      # Elements with "espi" namespace
      element :'espi:kind', class: Integer, as: :kind
  
      # Elements without namespace
      element :kind, class: Integer, as: :kind
    end
  end
end
