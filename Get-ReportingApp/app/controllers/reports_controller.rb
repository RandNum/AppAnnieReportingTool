class ReportsController < ApplicationController
  def index
    @reports = Report.all
    #@connections = Connection.order(:id).limit(10)
  end

  def show
    id = params[:id]
    puts "id is #{id}"
    @connections = Connection.where(:report => id)
    thisconnection = Connection.find(1)
    puts "thisconnection cpm is #{thisconnection.cpm}"
  end

  def new
  end

  def edit
  end
end
