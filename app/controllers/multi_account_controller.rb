require 'multi_account'
require 'remote_update'
class MultiAccountController < ApplicationController
  respond_to  :json
  def add_account
    Thread.new do
      puts "-------------------------------"
      puts permitted_params
      ob = Remote_edit_profile.new
      ob.update_remote_aws_config(permitted_params)
      if !permitted_params[:s3_bucket].nil?
        params = {}
        params.merge!({number: permitted_params[:arn][index+2..index+13], s3_bucket: permitted_params[:s3_bucket]})
        ob = Remote_edit.new
        ob.write_audit_log_input(params)
      end
    end
    render json: {"status" => "ok"}
  end

  private
  def permitted_params
    params.require(:account).permit(:arn, :s3_bucket)
  end
end
