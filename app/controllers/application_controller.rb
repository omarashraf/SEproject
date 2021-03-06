class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_filter :verify_authenticity_token  
  #Require help from the session helper located in app/controllers/helpers
  include SessionsHelper
	def current_user
   	 @current_user ||= User.find(session[:user_id]) if session[:user_id]
   	 rescue ActiveRecord::RecordNotFound
 	 end

  helper_method :current_user
end
