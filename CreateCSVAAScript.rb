require 'csv' 
require 'mysql2'
require 'active_record'

# Connect to an in-memory sqlite3 database
ActiveRecord::Base.establish_connection(
    adapter: 'mysql2',
    host: 'localhost',
    username: 'recorduser',
    password: 'annie',
    database: 'AAreportingDB'
)

# Define the models
class Report < ActiveRecord::Base
    has_many :connections, inverse_of: :report
end

class Connection < ActiveRecord::Base
    belongs_to :report, inverse_of: :connections, required: true
end

input_array = ARGV
start_date = input_array[0]
end_date = input_array[1]


file = "#{Rails.root}/AAexport.csv"

connections = Connection.order(:date)

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