class HermesController < ApplicationController

  # I'd like to have this return a list of topics
  # and their subscriber counts
  def index
    render :plain => 'OK', :status => 200
  end

  def publish
    ActionCable.server.broadcast(params.required(:topic), request.body.read)
    return render :status => 200
  end

end
