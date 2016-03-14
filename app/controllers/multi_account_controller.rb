require 'multi_account'
class MultiAccountController < ApplicationController
  respond_to  :json
  def add_account
    Thread.new do
      puts "-------------------------------"
      puts permitted_params
      ob = Remote_edit_profile.new
      ob.update_remote_aws_config(permitted_params)
      if !permitted_params[:s3_log_location].nil? # && !permitted_params[:s3_prefix].nil?
        ob = PaasService.new
        ob.write_audit_log_input(permitted_params)
      end
    end
    render json: {"status" => "ok"}
  end
  # redirect_to controller: "items"
  private
  def permitted_params
    params.require(:account).permit(:arn, :s3_log_location, :s3_log_prefix)
  end
end
