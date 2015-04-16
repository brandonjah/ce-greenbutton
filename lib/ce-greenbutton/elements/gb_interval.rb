# Copyright (C) 2015 TopCoder Inc., All Rights Reserved.
require 'sax-machine'

module GreenButton
  module Parser
    # a sax-machine mapping for the espi:Interval structure
    #
    # For example:
    #   interval = GbInterval.parse(open(interval.xml))
    #
    #
    # Author: ahmed.seddiq
    # Version: 1.0
    class GbInterval
      include SAXMachine

      # Elements with "espi" namespace
      element :'espi:duration', class: Integer,  as: :duration
      element :'espi:start',  class: Integer, as: :start
  
      # Elements without namespace
      element :duration, class: Integer,  as: :duration
      element :start,  class: Integer, as: :start
    end

  end
end
