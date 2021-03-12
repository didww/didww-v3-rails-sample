# frozen_string_literal: true
class LoginsController < ApplicationController
  layout 'login'

  def new
    redirect_to :root if logged_in?
  end

  def create
    if login_params[:api_key].empty?
      flash.now[:warning] = 'You must provide a valid API key.'
      render :new
      return
    end
    RequestStore.store.merge!(login_params)
    reload_user_balance  # if this doesn't fail, the credentials are valid
    session.merge!(login_params)
    flash[:success] = 'Signed in successfully'
    redirect_to session.delete(:redirect_to) || :root
  rescue JsonApiClient::Errors::NotAuthorized
    flash.now[:danger] = 'Login failed! Check API key and mode.'
    render :new
  end

  def destroy
    session[:api_key] = nil
    flash[:success] = 'Signed out successfully'
    redirect_to :login
  end

  private

  def login_params
    params.require(:login).permit(:api_key, :api_mode)
  end

end
