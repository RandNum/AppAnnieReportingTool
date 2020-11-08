class ConnectionsController < ApplicationController
  def index
    #@connections = Connection.order(:name).limit(100)
    
    @connections = Connection.all
  end

  def show
    
  end

  def new
  end

  def edit
  end
end
