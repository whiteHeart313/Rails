class AuthController < ApplicationController

  # Skip authentication for sign in/up actions
  skip_before_action :authenticate_request, only: [:sign_in, :sign_up]
  before_action :parse_request_body, only: [:sign_in , :sign_up]

  # POST /sign_up
  def sign_up
    user = User.new(user_params)
    if user.save
      token = jwt_encode(user_id: user.id)
      render json: { 
        message: "User created successfully",
        user: user.as_json(except: [:password_digest]), 
        token: token 
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /sign_in
  def sign_in
    user = User.find_by(email: @body_params["email"])
    
    if user&.authenticate(@body_params["password"])
      token = jwt_encode(user_id: user.id)
      render json: { 
        message: "Signed in successfully", 
        user: user.as_json(except: [:password_digest]), 
        token: token 
      }, status: :ok
    else
      render json: { errors: ["Invalid email or password"] }, status: :unauthorized
    end
  end

   # GET /profile
  def profile
    render json: { user: @current_user.as_json(except: [:password_digest]) }, status: :ok
  end

  # POST /refresh_token
  def refresh_token
    token = jwt_encode(user_id: @current_user.id)
    render json: { token: token }, status: :ok
  end

  private

  # Strong params for user
  def user_params
    params.permit(:email, :password,:first_name , :last_name) 
  end

  # JWT encode method
  def jwt_encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end

  # JWT decode method (for use in authentication filter)
  def jwt_decode(token)
    decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
    HashWithIndifferentAccess.new decoded
  rescue
    nil
  end

  # Parse request body for sign_in
  def parse_request_body
    @body_params = {}
    
    if request.content_type == 'application/json'
      raw_body = request.body.read
      @body_params = JSON.parse(raw_body) rescue {}
      request.body.rewind
    else
      @body_params = params.as_json
    end
  end
end