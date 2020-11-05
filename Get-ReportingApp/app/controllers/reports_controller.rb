class ReportsController < ApplicationController
  def index
    @reports = Report.all
    #@connections = Connection.order(:id).limit(10)
  end

  def show
  end

  def new
  end

  def edit
  end
end
