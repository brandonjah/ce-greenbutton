# Overview
GreenButton gem is a Ruby wrapper for the  [Green Button](http://www.greenbuttondata.org) Data. It allows third-party applications to retrieve the GreenButton data in the form of handy Ruby objects hiding the details of the XML representation and parsing.

## About the module
The GreenButton gem is designed for extendability and scalability. It provides a framework for processing the GreenButton data. It currently supports only the electricity consumption data, but plugins can be easily adapted to support new kinds of data.

The increased size of data by time was a significant factor in designing this module. To support this expected size of data, the [SAX parsing technique] is leveraged in this module.

### Why SAX and why sax-machine?
Unlike [DOM](http://en.wikipedia.org/wiki/Document_Object_Model), SAX need not to load the whole file into memory for parsing. It is an event driven parsing.
As we don't need power features of DOM like XPath for example, so SAX is ideal for data size scalability.


The [SAX Machine](https://github.com/pauldix/sax-machine) provides a simple and elegant binding interface that binds xml elements to Ruby objects and properties.

## Setup Prerequisites
1. [Latest Ruby SDK] (https://www.ruby-lang.org/en/)
[bundler](http://bundler.io/) is used to build and manage dependency.
2. [bundler](http://bundler.io/) is used to build and manage dependency.
3. [TomDoc](http://www.rubydoc.info/gems/tomdoc/0.2.5/frames#Installation) is used


## Installation

Using [bundler](http://bundler.io/), add this line to your application's Gemfile:

```ruby
gem 'ce-greenbutton'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ce-greenbutton

The parser uses [SAX Machine](https://github.com/pauldix/sax-machine) and will install it as dependency.

## Usage
A typical scenario of the module usage will be like this

The following will download and parse all data for subscription

```ruby
require 'greenbutton'
GreenButton.config(reg_access_token: "your access token",
                application_information_url: "http://app_info_url")
gb = GreenButton.download_data('your access token', 'http://greenbutton.data.url')
```

The following will download and parse all 2013 data for subscription

        ```ruby
        require 'ce-greenbutton'
        GreenButton.config(reg_access_token: "your access token",
                          application_information_url: "http://app_info_url")
        gb = GreenButton.download_data('your access token', 'http://greenbutton.data.url'
                                       Date.new(2013,1,1), Date.new(2013,12,31))

        ```
The following will download and parse data from FTP

        ```ruby
        require 'ce-greenbutton'
        GreenButton.config(reg_access_token: "your access token",
                          application_information_url: "http://app_info_url",
                          ftp_host: "your ftp host",
                          ftp_user: "your ftp user name",
                          ftp_password: "your ftp password",
                          ftp_path: "your ftp directory containing data")
        gb = GreenButton.download_data_ftp('your application id', Time.new(2015,3,19,1,1,1,0), "your utility name")
        ```

### Notes on usage
1. The access token is an OAuth2 access token.
2. The GreenButton.config must be called before the first call to download_data
3. You can test real data with the following values
    * registration access token: d89bb056-0f02-4d47-9fd2-ec6a19ba8d0c
    * application information url: https://services.greenbuttondata.org:443/DataCustodian/espi/1_1/resource/ApplicationInformation/2
    * access_token: 688b026c-665f-4994-9139-6b21b13fbeee
    * data url (resource): https://services.greenbuttondata.org/DataCustodian/espi/1_1/resource/Batch/Subscription/6
    * ftp_host: us1.hostedftp.com
    * ftp_user: clearlyenergy
    * ftp_password: store_clearly
    * ftp_path : SDGETest
    * application_id: 10066_CONSUMPTION
    * utility_name: CLEARLY
    * time (for ftp): Time.new(2015,3,19,1,1,1,0)


**Note, the call to `config` is mandatory before the first usage of the module.**

the returning result of the download_data or download_data_ftp call is an array of GbDataDescription
and it can be accessed like that.

```ruby
gb_data_descriptions.each do |gb_data_desc|
  gb_data = gb_data_desc.gb_data_array.first
  gb_data_reading = gb_data.interval_readings.first
  puts gb_data_reading.cost
end
```


## Limitations
1. Only the electricity consumption data is supported.
2. Only required data is extracted from the XML. For full list of required data,
check the `GbDataDescription`, `GbData` and `GbDataReading` classes in the
`model` directory.

## Extending Notes
The module is designed to ease extension in the following paths

1. Extract more information: that will be done by adding more elements to the
 parser in "greenbutton/elements"
2. Support more interpreters for different GreenButton data (like 'gas' for
example). This will be done by adding the interpreter implementation in the
"greenbutton/interpreters" directory.

### Supporting new kind of GreenButton data
1. Implement the new interpreter. Name the file as <service kind name>_interpreter.rb and put it in the interpreters folder.
  **NOTE  that this is very important as without this naming convention, the module may not be loaded as expected.**
2. Take the provided electricity_interpreter as a guide for the expected data.
3. It is preferred to use the following names for the different data kinds.
Using those names will make the interpreter loaded automatically.

```ruby
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
```
## Code Documentation
[TomDoc Notation](http://tomdoc.org/) was used to document code in this gem.

### TomDoc generation
To generate the docs:

*  The latest development version of the [TomDoc tool](https://github.com/defunkt/tomdoc) should be used as the published version seems to be out-dated. Refer to [TomDoc Local Development] (https://github.com/defunkt/tomdoc#local-dev) for instructions.
*  Use the console format (default), the HTML generator will not detect all docs.
*  To generate the console docs, just issue the following command for each file

         $ruby -rubygems /path/to/cloned/tomdoc/bin/tomdoc /path/to/tomdoced/code.rb

## Test
### Local data
Run a local web server on port 8123 and serve files under the `test_files` directory.
 Using  [NodeJS] (www.nodejs.org)

    $ npm install http-server -g
    $ cd test_files
    $ http-server -p 8123
**Note** You may need admin (root) privilege to install node/http-server

From the base directory of the module (the directory containing the .gemspec file.

    $ bundle install
    $ bundle exec rspec

Coverage reports will be found under the `coverage` subfolder.

## GreenButton API reference
- [Green Button Home](http://www.greenbuttondata.org)
- [Green Button API sandbox](http://energyos.github.io/OpenESPI-GreenButton-API-Documentation/API/)
- [GReen Button Concept overview](http://www.greenbuttondata.org/developers/)


### Reference this Ruby Gem Documentation
`tomdoc` was used to generate documentation files for this gem. The generated files are included in `docs` directory.


