class HermesController < ApplicationController

  def publish
    if request.put?
      return render :plain => "foo\n", :status => 200
    end

    render :plain => "use PUT to publish\n", :status => 405
  end

end
