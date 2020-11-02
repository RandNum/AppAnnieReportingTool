# Based on http://www.jonathanleighton.com/articles/2011/awesome-active-record-bug-reports/ 

# Run this script with `$ ruby GetReportingAAScript.rb`
require 'sqlite3'
require 'active_record'
require "uri"
require "net/http"
require "json"

# Use `binding.pry` anywhere in this script for easy debugging
#require 'pry'

# Connect to an in-memory sqlite3 database
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

# Define a minimal database schema
ActiveRecord::Schema.define do
  create_table :reports, force: true do |t|
    t.string :name
    #add query params? 
  end

  create_table :connections, force: true do |t|
    t.string :name #at least a simple iterator based on number of connections
    t.string :connection
    t.string :app
    t.string :country
    t.date :date
    t.decimal :impressions
    t.decimal :ad_revenue

    t.belongs_to :report, index: true
  end
end

# Define the models
class Report < ActiveRecord::Base
    has_many :connections, inverse_of: :report
end

class Connection < ActiveRecord::Base
    belongs_to :report, inverse_of: :connections, required: true
end

#Create the report object
report = Report.create!(name: 'new report')


input_array = ARGV
start_date = input_array[0]
end_date = input_array[1]

#puts "The Length of input_array is #{input_array.length}"

# Create the connection and get the reporting data:
url = URI("https://api.libring.com/v2/reporting/get\
?period=custom_date&start_date=#{start_date}&end_date=#{end_date}&data_type=adnetwork,acquisition&allow_mock=true&group_by=app,platform,country,connection")

https = Net::HTTP.new(url.host, url.port);
https.use_ssl = true


#handle pagination 
loop do
      request = Net::HTTP::Get.new(url)
      request["Authorization"] = "Token DHDwhdFXfoGBYLPOZPvTTwJoS"
      response = https.request(request)
      #puts response.read_body
      reportParsed = JSON.parse(response.read_body)
      connectionsParsed = reportParsed['connections']
      #puts "The number of connections is #{connectionsParsed.size}"


      # Create all of the connection objects from this page...
      count = 0
      connectionsParsed.each do |i|
          count+=1
          report.connections.create!(
              name: "connection #{count}",         #at least a simple iterator based on number of connections
              connection: i["connection"],
              app: i["app"],
              country: i["country"],
              date: i["date"],
              impressions: i["impressions"],
              ad_revenue: i["ad_revenue"]
          )
        end
      puts "Added #{count} connections from this page"
    if reportParsed["next_page_url"] == ""
      break
    end
    puts "Going to next page url at #{reportParsed["next_page_url"]}" 
    url = reportParsed["next_page_url"]
  end



connectionTypes = report.connections.pluck(:connection)
#puts "#{report.name} has #{report.connections.size} connections with connection types, #{connectionTypes.join(', ')}"
#output some test data 
