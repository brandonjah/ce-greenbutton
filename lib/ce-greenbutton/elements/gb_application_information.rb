# Copyright (C) 2015 TopCoder Inc., All Rights Reserved.
require 'sax-machine'
module GreenButton
  module Parser
    # a sax-machine mapping for the ApplicationInformation structure.
    #
    # For example
    #   app_info = GbApplicationInformation.parse(open(application_information.xml))
    #
    # Author ahmed.seddiq
    # Version 1.0
    class GbApplicationInformation
      include SAXMachine
      # Elements with "espi" namespace
      element :'espi:dataCustodianId', as: :data_custodian_id

      # Elements without namespace
      element :dataCustodianId, as: :data_custodian_id
    end
  end
end
