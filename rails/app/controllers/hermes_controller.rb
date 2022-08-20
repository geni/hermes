class HermesController < ApplicationController

  def index
    render :plain => 'OK', :status => 200
  end

  def dashboard
    @dashboard = Dashboard.new
    render :json => @dashboard.to_json
  end

  def publish
    ActionCable.server.broadcast(params.required(:topic), request.body.read)
    return render :status => 200
  end

end
