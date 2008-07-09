class PulseController < ApplicationController
  session :off
  def pulse
    if (ActiveRecord::Base.connection.execute("select 1").num_rows rescue 0) == 1
      render :text => "OK #{Time.now.utc.to_s(:db)}"
    else
      render :text => 'ERROR', :status => :internal_server_error
    end
  end
end
