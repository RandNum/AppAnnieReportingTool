class ConnectionsController < ApplicationController
  def index
    @connections = Connection.order(:name).limit(10)
  end

  def show
    @connection = Connection.find(params[:id])
  end

  def new
  end

  def edit
  end
end
