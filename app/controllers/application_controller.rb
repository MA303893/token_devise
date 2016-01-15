require 'ridley'
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end
  respond_to :html, :json
  protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/json'}
  skip_before_filter :verify_authenticity_token#, :if => Proc.new { |c| c.request.format == 'application/json' }

  # before_action :authenticate_user!, :except => [:sign_in, :sign_up]
  before_action :authenticate_user_from_token!, :except => [:sign_in, :sign_up], unless: :devise_controller?
  before_action :authenticate_user!, :except => [:sign_in, :sign_up], unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  
  def authenticate_user_from_token!
    user_email = request.headers["X-API-EMAIL"].presence
    user_auth_token = request.headers["X-API-TOKEN"].presence
    user = user_email && User.find_by_email(user_email)

    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && Devise.secure_compare(user.authentication_token, user_auth_token)
      sign_in(user, store: false)
    end
  end

  def add_allow_credentials_headers
    response.headers['Access-Control-Allow-Origin'] = request.headers['Origin'] || '*'
    response.headers['Access-Control-Allow-Credentials'] = 'true'
  end

  def options
    head :status => 200, :'Access-Control-Allow-Headers' => 'accept, content-type'
  end

  private

  def user_not_authorized
    logger.info "D"*100
    head 403
    flash[:error] = "You are not authorized to perform this action."
    redirect_to request.referrer
  end

  def record_not_found(exception)
    logger.info "Record with ID #{params[:id]}"
    flash[:error] = "Requested Record with ID : #{params[:id]} not found."
    redirect_to request.referrer
  end

  protected

  def authenticate_user!
    if user_signed_in?
      super
    else
      respond_to do |format|
        format.html {redirect_to user_session_path, :notice => "You've to be logged in to access this page"}
        format.json { render json: { success: false, message: 'Error with your login or password' }, status: 401 }
      end
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:firstname, :lastname, :email, :password, :password_confirmation) }
  end
end
