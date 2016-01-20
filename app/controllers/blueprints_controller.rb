class BlueprintsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :html, :json

  def index
    @blueprint = Blueprint.all
    respond_to do |format|
      format.html
      format.json {render json: @blueprint.to_json}
    end
  end

  def create
    @blueprint = Blueprint.new
    id = @blueprint.save(permitted_params)
    @blueprint = Blueprint.find(id)
    respond_to do |format|
      format.html {redirect_to tenant_subscription_blueprint_path(id: id)}
      format.json {render json: @blueprint.to_json}
    end

  end

  def destroy
    @blueprint =  Subscription.find(params[:id])
    @blueprint.destroy
    # redirect_to tenants_path
    respond_to do |format|
      format.html  {redirect_to tenant_subscription_blueprints_path}
      format.json  { render :json => {status: "ok"}, status: 202 }
    end
  end

  def update
    @blueprint = Blueprint.find(params[:id])
    if @blueprint.nil?
      render file: '/public/404.html',status: 404
    else
      @blueprint = @blueprint.update(permitted_params,params[:id])
      respond_to do |format|
        format.html {redirect_to tenant_subscription_blueprint_path(params[:id])}
        format.json {render json: @blueprint.to_json}
      end
    end

  end

  def show
    @blueprint = Blueprint.find(params[:id])
    if @blueprint.nil?
      render file: '/public/404.html',status: 404
    end
    respond_to do |format|
      format.html #{redirect_to tenant_subscription_blueprint_path(id: id)}
      format.json {render json: @blueprint.to_json}
    end
  end

  def edit
    @blueprint = Blueprint.find(params[:id])
  end

  def new
    @blueprint = Blueprint.new
  end

  private
  def permitted_params
    params.require(:blueprint).permit(:name, :display_name).merge!(tenant_id: params[:tenant_id], subscription_id: params[:subscription_id])
  end
end
