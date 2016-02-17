require 'remote_update'
class PaasServicesController < ApplicationController
  def write_service

    ob = Remote_edit.new
    if params.has_key?(:s3)
      Thread.new do
        ob.write_s3(params)
      end
      render json: {"status" => "ok"}
    elsif params.has_key?(:rds)
      Thread.new do
        ob.write_rds(params(:rds))
      end
      render json: {"status" => "ok"}
    elsif params.has_key?(:elb)
      Thread.new do
        ob.write_elb(params)
      end
      render json: {"status" => "ok"}
    elsif params.has_key?(:autoscaling)
      Thread.new do
        ob.write_asg(params(:autoscaling))
      end
      render json: {"status" => "ok"}

    end

  end
  private
  def permitted_params
    if params.has_key?(:autoscaling)
      params.require(:autoscaling).permit(:account, :region, :name, :tenant, :subscription, :blueprint, :metrics, :refresh_interval)
    elsif params.has_key?(:s3)
        
    end
  end

end



