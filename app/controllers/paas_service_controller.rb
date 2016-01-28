require 'remote_update'
class PaasServiceController < ApplicationController
  respond_to  :json
  def write_to_remote_audit_log_input_txt
  	Thread.new do
      ob = Remote_edit.new
      ob.write_audit_log_input(permitted_params)
    end
    render json: {"status" => "ok"}
  end
  private
  def permitted_params
    params.require(:account).permit(:number, :region, :s3_bucket)
  end
end
