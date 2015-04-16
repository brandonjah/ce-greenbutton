# Copyright (C) 2015 TopCoder Inc., All Rights Reserved.

require 'open-uri'
require 'date'
require 'ce-greenbutton/parser'
require 'ce-greenbutton/elements/gb_application_information'
require 'ce-greenbutton/elements/gb_entry'

# The main entry of the module. provides the download_data method that will
#   download and parse GreenButton data.
# For example:
#   # The following will download and parse all data for subscription
#   require 'ce-greenbutton'
#   GreenButton.config(reg_access_token: "your access token"
#                      application_information_url: "http://app_info_url")
#   gb = GreenButton.download_data('your access token', 'http://greenbutton.data.url')
#   # => [gb_data_description]
#
#   # The following will download and parse all data for 2013
#   require 'date'
#   require 'ce-greenbutton'
#   GreenButton.config(reg_access_token: "your access token"
#                      application_information_url: "http://app_info_url")
#   gb = GreenButton.download_data('your access token',
#         'http://greenbutton.data.url'), Date.new(2013,1,1), Date.new(2013,12,31))
#   # => [gb_data_description]
#
#
# Changes for v1.1 (SunShot - Clearly Energy GreenButton Ruby Gem Update)
#   1. added new method download_data_ftp
#   2. parsing code is refactored to parse_data private method.
#   3. download_data method is updated to use the parse_data method.
#   4. config method is updated to support ftp options.
#   5. check_config method is updated to check ftp options.
#   6. added check_arguments_ftp method.
#
# Author: ahmed.seddiq
# Version: 1.1
module GreenButton

  # Constant: the known data kind names mapped to the kind value,
  #  the values are retrieved from the GreenButton xml schema.
  SERVICEKIND_NAMES = {
      0 => 'electricity',
      1 => 'gas',
      2 => 'water',
      3 => 'time',
      4 => 'heat',
      5 => 'refuse',
      6 => 'sewerage',
      7 => 'rates',
      8 => 'tvLicence',
      9 => 'internet'
  }

  # Hash used to hold registered GreenButton data interpreters.
  # Key is the kind value of the data, the value is the interpreter module.
  @interpreters = {}

  # Public: Gets the interpreter of the given kind.
  # kind  - the kind of the GreenButton Data
  # Returns the registered interpreter for the given kind, or nil if none found.
  def self.interpreter(kind)
    @interpreters[kind]
  end

  # Public: Downloads and parses the GreenButton data for the given
  #   subscription. It also allows to filter returned readings by date.
  #
  # access_token        - represents the retail customer access token.
  # subscription_id     - represents the retail customer resourceURI.
  # interval_start_time - represents the start date to retrieve data.
  # interval_end_time   - represents the end date to retrieve data.
  #
  # Examples
  #
  #   # The following will download and parse all data for 2013
  #   require 'date'
  #   require 'ce-greenbutton'
  #   gb = GreenButton.download_data('688b026c-665f-4994-9139-6b21b13fbeee', 5,
  #         Date.new(2013,1,1), Date.new(2013,12,31))
  #   # => [gb_data_description]
  #
  # Returns an array of gb_data_description
  # Raises ArgumentError if any passed argument is invalid.
  # Propagates errors from OpenURI for any connection/authentication
  def self.download_data(access_token, subscription_id,
      interval_start_time = nil, interval_end_time = nil)
    check_arguments(access_token, subscription_id, interval_start_time,
                    interval_end_time)

    # Construct the resource url
    resource_url = subscription_id
    params = []
    if interval_start_time
      params << "published-min=#{interval_start_time.to_s}"
    end
    if interval_end_time
      params << "published-max=#{interval_end_time.to_s}"
    end
    resource_url += (resource_url.index('?').nil?? '?':'&')+ params.join('&') if
                params.length > 0
    data = open(resource_url,
                'Authorization' => "Bearer #{access_token}")
    parse_data(access_token, data) #Return
  end

  # Public: Downloads and parses the GreenButton data, hosted in a FTP server.
  # The FTP host, user, password and path is configured through the config
  # method.
  # The File name is constructed as follows:
  #  D_{utility_name}_{application_id}_{YYYYMMDDHHMMSS}.XML.
  #
  # application_id  - represents the GreenButton 3rd party application id.
  # time            - used to construct file name. (optional, defaults
  #                   to current time)
  # utility_name    - represents the utility name, used to construct the
  #                   XML file name.
  #
  # Returns an array of gb_data_description
  # Raises ArgumentError if any passed argument is invalid.
  # Propagates errors from OpenURI for any connection/authentication
  def self.download_data_ftp(application_id, time=Time.now, utility_name)
    check_arguments_ftp(application_id, time, utility_name)

    # construct the ftp url
    ftp_url = "ftp://#{@ftp_user}:#{@ftp_password}@#{@ftp_host}/#{@ftp_path}/" +
      "D_#{utility_name}_#{application_id}_#{time.strftime('%Y%m%d%H%M%S')}.XML"

    parse_data(open(ftp_url))
  end

  # Parses the given greenbutton data to the corresponding ruby objects.
  #
  # user_id - identifies the owner of the data.
  # data    - The source GreenButton xml data, can be string, or any stream returning
  #         from a call to open(uri)
  #
  # Returns the parsed array of gb_data_description
  private
  def self.parse_data(user_id = nil, data)
    # get ApplicationInformation
    app_info = GreenButton::Parser::GbApplicationInformation.
        parse(open(@application_information_url,
                   'Authorization' => "Bearer #{@reg_access_token}"))

    feed = GreenButton::Parser.parse(data)
    gb = []
    unsupported_kinds = []
    feed.entries.each_pair do |key, entry|
      if entry.is_a? GreenButton::Parser::GbEntry
        if entry.type == 'UsagePoint'
          usage_point = entry.content.usage_point
          if @interpreters[usage_point.kind].nil?
            unsupported_kinds << usage_point.kind
          else
            gb_data_description = @interpreters[usage_point.kind]
                                      .get_gb_data_description(entry, feed)
            gb_data_description.custodian = app_info.data_custodian_id
            gb_data_description.user_id = user_id unless user_id.nil?
            gb << gb_data_description
          end

        end
      end
    end
    if gb.length == 0 and unsupported_kinds.length > 0
      raise InvalidGbDataError, "Received unsupported GreenButton data #{unsupported_kinds.to_s}
          Only Electricity (kind = 0) is supported."
    end
    gb
  end


  # Public: Registers a new Interpreter for the given data kind.
  #
  # kind                - represents the kind of GreenButton data.
  # interpreter_name    - the name of the interpreter (String or Symbol)
  #
  # Examples
  #
  #   # To register an interpreter for the gas data (kind = 1)
  #   # implement the interpreter with name
  #   #  GreenButton::Interpreters::GasInterpreter
  #   gb = GreenButton.register_interpreter(1, :gas)
  #
  # Returns nothing.
  # Raises ArgumentError if any passed argument is invalid.
  def self.register_interpreter(kind, interpreter_name)
    unless kind.is_a?Integer and kind >= 0
      raise ArgumentError, 'kind must be positive integer'
    end
    unless interpreter_name.is_a?Symbol or interpreter_name.is_a?String
      raise ArgumentError, 'interpreter_name must be symbol or string'
    end
    require "ce-greenbutton/interpreters/#{interpreter_name}_interpreter"
    @interpreters[kind] = GreenButton::Interpreters.const_get(
        "#{interpreter_name.to_s.capitalize}Interpreter")
  end


  # Public: configures the GreenButton module. It must be called before usage.
  #
  # Supported properties:
  #   reg_access_token: The registration access token, required,
  #   application_information_url: required,
  #   ftp-host: required for download_data_ftp,
  #   ftp-user: required for download_data_ftp,
  #   ftp-password: required for download_data_ftp,
  #   ftp-path: the ftp directory path with no leading or trailing backslashes,
  # optional for download_data_ftp, defaults to empty string.
  #
  # For example:
  #   GreenButton.config(reg_access_token: 'your access token',
  #                      application_information_url: 'http://app_info_url',
  #                      ftp-host: 'your-ftp-host',
  #                      ftp-user: 'ftp-user',
  #                      ftp-password: 'ftp-password',
  #                      ftp-path: 'path/to/ftp/directory' )
  #
  # Returns nothing.
  #
  def self.config(options = {})
    @reg_access_token = options[:reg_access_token] || options['reg_access_token']
    @application_information_url = options[:application_information_url] ||
        options['application_information_url']
    @ftp_host = options[:ftp_host] || options['ftp_host']
    @ftp_user = options[:ftp_user] || options['ftp_user']
    @ftp_password = options[:ftp_password] || options['ftp_password']
    @ftp_path = options[:ftp_path] || options['ftp_path'] || ''
  end

  # try to load interpreters
  SERVICEKIND_NAMES.each_pair do |kind, name|
    begin
      self.register_interpreter kind, name
    rescue LoadError
      # ignored
    end
  end

  # Helper method to check arguments' validity of the download_data method.
  #
  # access_token        - represents the retail customer access token.
  # subscription_id     - represents the retail customer resourceURI.
  # interval_start_time - represents the start date to retrieve data (optional).
  # interval_end_time   - represents the end date to retrieve data (optional).
  #
  # Returns nothing.
  # Raises ConfigurationError If the GreenButton was not configured by
  #                           GreenButton.config prior to usage.
  # Raises ArgumentError if any passed argument is invalid.
  private
  def self.check_arguments(access_token, subscription_id, interval_start_time,
      interval_end_time)
    check_config

    unless access_token.is_a? String and access_token.strip.length > 0
      raise ArgumentError, 'access_token must be a non-empty string.'
    end
    unless subscription_id =~ URI::regexp
      raise ArgumentError, 'subscription_id must be a valid url'
    end
    unless interval_start_time.nil? or interval_start_time.is_a? Date
      raise ArgumentError, 'interval_start_time must be a valid Date object.'
    end
    unless interval_end_time.nil? or interval_end_time.is_a? Date
      raise ArgumentError, 'interval_end_time must be a valid Date object.'
    end
  end

  # Helper method to check arguments' validity of the download_data_ftp method.
  #
  # application_id  - represents the GreenButton 3rd party application id.
  # time            - used to construct file name. (optional, defaults
  #                   to current time)
  # utility_name    - represents the utility name, used to construct the
  #                   XML file name.
  #
  # Returns nothing.
  # Raises ConfigurationError If the GreenButton was not configured by
  #                           GreenButton.config prior to usage.
  # Raises ArgumentError if any passed argument is invalid.
  def self.check_arguments_ftp(application_id, time , utility_name)
    # check module configuration with ftp options.
    check_config(true)
    unless application_id.is_a? String and application_id.strip.length > 0
      raise ArgumentError, 'application_id must be a non-empty string.'
    end

    unless utility_name.is_a? String and utility_name.strip.length > 0
      raise ArgumentError, 'utility_name must be a non-empty string.'
    end

    unless time.is_a? Time
      raise ArgumentError, 'time must be a Time object.'
    end
  end

  # Checks is the module is properly configured.
  #
  # ftp - whether to check ftp-related options.
  #
  # Raises ConfigurationError if any required configuration is missing.
  def self.check_config(ftp=false)
    if @application_information_url.nil?
      raise ConfigurationError, 'application_information_url is not set, please call
                           GreenButton.config first'
    end
    if @reg_access_token.nil?
      raise ConfigurationError, 'registration access token is not set please call
                           GreenButton.config first'
    end

    if ftp
      if @ftp_host.nil?
        raise ConfigurationError, 'ftp_host is not set, please call
                           GreenButton.config first'
      end
      if @ftp_user.nil?
        raise ConfigurationError, 'ftp_user is not set, please call
                           GreenButton.config first'
      end
      if @ftp_password.nil?
        raise ConfigurationError, 'ftp_password is not set, please call
                           GreenButton.config first'
      end
    end
  end

  # This error will be raised if the download_data method was called before calling
  #   the GreenButton.config
  #
  # Author: ahmed.seddiq
  # Version: 1.0
  class ConfigurationError < Exception

  end

  # Will be raised if a parsing or semantic error occurred during the data
  #  parsing/interpretation
  #
  # For example, if the data does not contain a LocalTimeParameters structure
  #
  # Author: ahmed.seddiq
  # Version: 1.0
  class InvalidGbDataError < Exception

  end


end
