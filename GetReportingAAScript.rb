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
@start_date = input_array[0] == nil ? today : input_array[0]
@end_date = input_array[1] == nil ? today : input_array[1]

initial_fetch_url = "https://api.libring.com/v2/reporting/get\
?period=custom_date&start_date=#{@start_date}&end_date=#{@end_date}&data_type=adnetwork,acquisition&allow_mock=true&group_by=app,platform,country,connection"
@report = Report.create!(name: "Report-#{@start_date}-#{@end_date}" )



def findNextUrl(response)
  return response["next_page_url"] == nil ? "" : response["next_page_url"]
end

def addAuthHeader(request)
  request["Authorization"] = "Token DHDwhdFXfoGBYLPOZPvTTwJoS"
end

def processConnection(connection, count)
  adrev = connection["ad_revenue"].to_d
  impres = connection["impressions"].to_d 
  cpm = adrev/(impres/1000.0)
  #puts "adrev is #{adrev} and impres is #{impres} and cpm is #{cpm}"
  count+=1
  @report.connections.create!(
      name: @report.name,         #at least a simple iterator based on number of connections
      connection: connection["connection"],
      app: connection["app"],
      platform: connection["platform"],
      country: connection["country"],
      date: connection["date"],
      impressions: connection["impressions"].to_d,
      ad_revenue: connection["ad_revenue"].to_d,
      cpm: cpm
  )
end

def reportOucome
  count = Connection.where(:date => @start_date..@end_date ).where(:report => @report.id).count
  puts "Ingested #{count} reults"
end

url = URI(initial_fetch_url)
https = Net::HTTP.new(url.host, url.port)
https.use_ssl = true

loop do
  puts "Going to next page url at #{url}" 
  request = Net::HTTP::Get.new(url)
  addAuthHeader(request)

  response = JSON.parse(https.request(request).read_body)
  connectionsParsed = response['connections']

  # Create all of the connection objects from this page...
  count = 0
  connectionsParsed.each do |conn|
    processConnection(conn, count)
  end

  puts "Added #{connectionsParsed.length} connections from this page"

  url = findNextUrl(response)
  break if url.length == 0
end

reportOucome()

