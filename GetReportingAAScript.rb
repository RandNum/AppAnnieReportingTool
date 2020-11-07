# Add data to database with Data from AppAnnie Reporting API

require 'mysql2'
require 'active_record'
require "uri"
require "net/http"
require "json"
require 'date'

require_relative 'Get-ReportingApp/app/models/application_record'
require_relative 'Get-ReportingApp/app/models/report'
require_relative "Get-ReportingApp/app/models/connection"

# Connect to an in-memory sqlite3 database
ActiveRecord::Base.establish_connection(
  adapter: 'mysql2',
  host: 'localhost',
  username: 'recorduser',
  password: 'annie',
  database: 'AAreportingDB'
)

input_array = ARGV
today = Time.now.strftime("%Y-%m-%d")
start_date = input_array[0] == nil ? today : input_array[0]
end_date = input_array[1] == nil ? today : input_array[1]

# Create the connection and get the reporting data:
url = URI("https://api.libring.com/v2/reporting/get\
?period=custom_date&start_date=#{start_date}&end_date=#{end_date}&data_type=adnetwork,acquisition&allow_mock=true&group_by=app,platform,country,connection")
https = Net::HTTP.new(url.host, url.port);
https.use_ssl = true

#Create the report object
report = Report.create!(name: "Report#{start_date}to#{end_date}" )
#handle pagination and create connection objects 
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
          adrev = i["ad_revenue"].to_d
          impres = i["impressions"].to_d 
          cpm = adrev/(impres/1000.0)
          #puts "adrev is #{adrev} and impres is #{impres} and cpm is #{cpm}"
          count+=1
          report.connections.create!(
              name: "connection #{count}",         #at least a simple iterator based on number of connections
              connection: i["connection"],
              app: i["app"],
              platform: i["platform"],
              country: i["country"],
              date: i["date"],
              impressions: i["impressions"],
              ad_revenue: i["ad_revenue"],
              cpm: cpm
          )
        end
      puts "Added #{count} connections from this page"
      #puts "CPM is #{report.connections.pluck("cpm").to_s}"
    if reportParsed["next_page_url"] == ""
      break
    end
    puts "Going to next page url at #{reportParsed["next_page_url"]}" 
    url = reportParsed["next_page_url"]
  end


connectionsDateQuery = Connection.where(:date => start_date..end_date ).order(:app)
puts "Query test shows connectionsDateQuery returned #{connectionsDateQuery.size} reults"



connectionTypes = report.connections.pluck(:connection)
#puts "#{report.name} has #{report.connections.size} connections with connection types, #{connectionTypes.join(', ')}"
#output some test data 
