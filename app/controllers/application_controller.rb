class ApplicationController < ActionController::API
  before_action :authenticate_request!
  rescue_from StandardError, with: :rescue_from_exception
  attr_reader :current_user
  

  def route_not_found
      render json: { error: 'Route not found' }, status: :not_found
  end
  private
  def rescue_from_exception(exception)
    Rails.logger.error "Exception: #{exception.message}"
    render json: { errors: [exception.message] }, status: :internal_server_error
  end
  
  def authenticate_request!
    @current_user = authorize_api_request
    render json: { errors: ['Not Authorized'] }, status: :unauthorized unless @current_user
  end
  
  def authorize_api_request
    auth_header = request.headers['Authorization']
    token = auth_header.split(' ').last if auth_header
    
    begin
      decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
      @decoded_auth_token = HashWithIndifferentAccess.new(decoded)
      user_id = @decoded_auth_token[:user_id]
      
      User.find(user_id)
    rescue JWT::DecodeError, JWT::ExpiredSignature, ActiveRecord::RecordNotFound => e
      Rails.logger.error "Authentication error: #{e.message}"
      nil
    end
  end
end
