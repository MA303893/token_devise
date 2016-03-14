class PaasServicesController < ApplicationController

  before_action :init
  def init
    @ob = PaasService.new
  end
  def write_paas_data_to_es

    if params.has_key?(:s3)
      @ob.s3(permitted_params)
      render json: {"status" => "ok"}
    elsif params.has_key?(:rds)
      @ob.rds(permitted_params)
      render json: {"status" => "ok"}
    elsif params.has_key?(:elb)
      @ob.elb(permitted_params)
      render json: {"status" => "ok"}
    elsif params.has_key?(:autoscaling)
      @ob.asg(permitted_params)
      render json: {"status" => "ok"}
    else
      render :json => { :message => 'Invalid Prameters.' }, :status => 404
    end

  end

  def delete_paas_data_from_es
    if params.has_key?(:s3)
      @ob.delete_paas_from_es(permitted_params, 's3')
      render json: {"status" => "ok"}
    elsif params.has_key?(:autoscaling)
      @ob.delete_paas_from_es(permitted_params, 'asg')
      render json: {"status" => "ok"}
    elsif params.has_key?(:rds)
      @ob.delete_paas_from_es(permitted_params, 'rds')
      render json: {"status" => "ok"}
    elsif params.has_key?(:elb)
      @ob.delete_paas_from_es(permitted_params, 'elb')
      render json: {"status" => "ok"}
    else
      render :json => { :message => 'Invalid Prameters.' }, :status => 404
    end
  end



  private
  def permitted_params
    if params.has_key?(:autoscaling)
      params.require(:autoscaling).permit(:account, :region, :name, :tenant, :subscription, :blueprint,  :refresh_interval, :asg_identifier).merge!(metrics: params[:autoscaling][:metrics])
    elsif params.has_key?(:s3)
      params.require(:s3).permit(:account, :region, :name, :tenant, :subscription, :blueprint, :refresh_interval,:s3_log_location, :s3_log_prefix).merge!(metrics: params[:s3][:metrics])
    elsif params.has_key?(:rds)
      params.require(:rds).permit(:account, :region, :name, :endpoint, :tenant, :subscription, :blueprint, :refresh_interval, :endpoint, :rds_engine, :db_identifier).merge!(metrics: params[:rds][:metrics])
    elsif params.has_key?(:elb)
      params.require(:elb).permit(:account, :region, :name, :tenant, :subscription, :blueprint,  :refresh_interval, :s3_log_location, :s3_log_prefix, :dns_name, :elb_identifier).merge!(metrics: params[:elb][:metrics])
    end
  end

end
