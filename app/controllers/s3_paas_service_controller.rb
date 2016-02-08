require 'remote_update'
class S3PaasServiceController < ApplicationController
  def write_to_s3

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
    elsif params.has_key?(:asg)
      Thread.new do
        ob.write_asg(params(:asg))
      end
      render json: {"status" => "ok"}

    end

  end

end
