class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :logged_in?

  before_action :fetch_dynamic_credentials

  rescue_from JsonApiClient::Errors::NotAuthorized, with: :api_not_authorized_error
  rescue_from JsonApiClient::Errors::ConnectionError, with: :api_connection_error
  rescue_from JsonApiClient::Errors::ServerError, with: :api_server_error

  private

  def logged_in?
    !!session[:api_key]
  end

  def reload_user_balance
    # rises JsonApiClient::Errors::NotAuthorized etc..
    balance = DIDWW::Client.balance
    session[:cached_balance] = balance.attributes.except(:type, :id)
  end

  def fetch_dynamic_credentials
    RequestStore.store.merge!(session.to_hash.slice('api_key', 'api_mode'))
  end

  def api_not_authorized_error
    flash[:danger] = 'Please enter your api key again.'
    drop_session
  end

  def api_connection_error
    flash[:danger] = "Couldn't connect to the server. Please try again later."
    drop_session
  end

  def api_server_error
    flash[:danger] = 'Sorry, something went wrong on our side.'
    drop_session
  end

  def drop_session
    session.delete(:api_key)
    redirect_to :login
  end

end
