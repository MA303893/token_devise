class TenantsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :html, :json
  def index
    @tenants = Tenant.all
  end

  def new
    @tenant = Tenant.new
  end

  def create
    @tenant = Tenant.new
    id = @tenant.save(permitted_params)
    @tenant = Tenant.find(id)
    respond_to do |format|
      format.html {redirect_to tenant_path(id)}
      format.json {render json: {id: @tenant.id, name: @tenant.name, display_name: @tenant.display_name}}
    end
    #redirect_to tenant_path(id)
  end

  def destroy
    @tenant =  Tenant.find(params[:id])
    @tenant.destroy
    # redirect_to tenants_path
    respond_to do |format|
      format.html  {redirect_to tenants_path}
      format.json  { render :json => {status: "ok"}, status: 202 }
    end
  end

  def show
    @tenant = Tenant.find(params[:id])
    if @tenant.nil?
      render file: '/public/404.html', status: 404
    end
  end

  def edit
    @tenant = Tenant.find(params[:id])
    if @tenant.nil?
      render file: '/public/404.html', status: 404
    end
  end

  def update
    tenant_result = Tenant.find(params[:id])
    if tenant_result.nil?
      render file: '/public/404.html', status: 404
    else
      @tenant = tenant_result.update(permitted_params,params[:id])
      respond_to do |format|
        format.html {redirect_to tenant_path(params[:id])}
        format.json {render json: { id: @tenant.id, name: @tenant.name, display_name: @tenant.display_name}}
      end
      
    end

  end

  private
  def permitted_params
    params.require(:tenant).permit(:name, :display_name)
  end
end
