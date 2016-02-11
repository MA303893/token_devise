require 'multi_account'
class MultiAccountController < ApplicationController
	respond_to  :json
  def add_account
  	Thread.new do
  		puts "-------------------------------"
      puts permitted_params
      ob = Remote_edit_profile.new
      ob.update_remote_aws_config(permitted_params)

    end
    render json: {"status" => "ok"}
  end

  private
  def permitted_params
    params.require(:account).permit(:arn, :region)
  end
end
