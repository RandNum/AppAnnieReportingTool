require 'csv' 
require 'mysql2'
require 'active_record'

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
start_date = input_array[0]
end_date = input_array[1]
demensions = input_array[2]

file = "AAexport.csv"

connections = Connection.where(:date=>start_date..end_date).order(:date)

headers = ["Name", "Connection Type", "App", "Platform", "Country", "Date", "Impressions", "Ad Revenue", "CPM"]

CSV.open(file, 'w', write_headers: true, headers: headers) do |writer|
  connections.each do |connection| 
  writer << [connection.name, 
    connection.connection,
    connection.app,
    connection.platform,
    connection.country,
    connection.date,
    connection.impressions,
    connection.ad_revenue,
    connection.cpm] 
  end
end