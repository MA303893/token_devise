require 'remote_update'
class PaasServicesController < ApplicationController
  def write_service

    ob = Remote_edit.new

    if params.has_key?(:s3)
      puts "s3"*100
      puts permitted_params
      ob.s3(permitted_params)
      render json: {"status" => "ok"}
    elsif params.has_key?(:rds)
      ob.write_rds(permitted_params)
      render json: {"status" => "ok"}
    elsif params.has_key?(:elb)
      ob.elb(permitted_params)
      render json: {"status" => "ok"}
    elsif params.has_key?(:autoscaling)
      ob.asg(permitted_params)
      render json: {"status" => "ok"}
    end

  end
  private
  def permitted_params
    if params.has_key?(:autoscaling)
      params.require(:autoscaling).permit(:account, :region, :name, :tenant, :subscription, :blueprint,  :refresh_interval).merge!(metrics: params[:autoscaling][:metrics])
    elsif params.has_key?(:s3)
      params.require(:s3).permit(:account, :region, :name, :tenant, :subscription, :blueprint, :refresh_interval).merge!(metrics: params[:s3][:metrics])
    elsif params.has_key?(:rds)
      params.require(:rds).permit(:account, :region, :name, :endpoint, :tenant, :subscription, :blueprint, :refresh_interval).merge!(metrics: params[:rds][:metrics])
    elsif params.has_key?(:elb)
      params.require(:elb).permit(:account, :region, :name, :tenant, :subscription, :blueprint,  :refresh_interval).merge!(metrics: params[:elb][:metrics])
    end
  end

end
