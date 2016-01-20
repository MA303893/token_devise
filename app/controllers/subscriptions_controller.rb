class SubscriptionsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :html, :json

  def index
    @tenant =  Tenant.find(params[:tenant_id])
    #@subscriptions = @tenant.subscriptions
    @subscriptions =  Subscription.all
  end

  def create
    @subscription = Subscription.new
    @subscription.tenant_id = params[:tenant_id]
    id = @subscription.save(permitted_params)
    @subscription = Subscription.find(id)
    puts @subscription.to_json
    respond_to do |format|
      format.html {redirect_to tenant_subscription_path(id: id)}
      format.json {render json: @subscription.to_json}
    end
  end

  def show
    @subscription = Subscription.find(params[:id])
    if @subscription.nil?
      render file: '/public/404.html', status: 404
    end
  end

  def edit
    @subscription = Subscription.find(params[:id])
  end

  def update
    subscription_result = Subscription.find(params[:id])
    if subscription_result.nil?
      render file: '/public/404.html', status: 404
    else
      @subscription = subscription_result.update(permitted_params,params[:id])
      respond_to do |format|
        format.html {redirect_to tenant_subscription_path(params[:id])}
        format.json {render json: @subscription.to_json}
      end

    end
  end
  def destroy
    @subscription =  Subscription.find(params[:id])
    @subscription.destroy
    # redirect_to tenants_path
    respond_to do |format|
      format.html  {redirect_to tenant_subscriptions_path}
      format.json  { render :json => {status: "ok"}, status: 202 }
    end
  end

  def new
    @subcriptions = Subscription.new
  end

  private
  def permitted_params
    params.require(:subscription).permit(:name, :display_name, :budget).merge!(tenant_id: params[:tenant_id])
  end
end
