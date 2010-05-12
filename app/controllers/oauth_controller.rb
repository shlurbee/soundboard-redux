# TODO: DOC

gem 'soundcloud-ruby-api-wrapper'
require 'soundcloud'

# NOTE: $sc_consumer and $sc_host are defined in config/environment.rb
class OauthController < ApplicationController
  def request_token
    callback_url = url_for :action => :access_token
    request_token = $sc_consumer.get_request_token(:oauth_callback => callback_url)
    session[:request_token] = request_token.token
    session[:request_token_secret] = request_token.secret
    authorize_url = "http://#{$sc_host}/oauth/authorize?" + 
      "oauth_token=#{request_token.token}&oauth_callback=#{callback_url}&display=popup"
    redirect_to authorize_url
  end

  def access_token
    request_token = OAuth::RequestToken.new($sc_consumer,
      session[:request_token],
      session[:request_token_secret])
    access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
    sc = Soundcloud.register({:access_token => access_token, :site => "http://api.#{$sc_host}"})
    me = sc.User.find_me
    # auth successful. save info in the session
    session[:access_token] = access_token.token
    session[:access_token_secret] = access_token.secret
    # Redirecting to sc-connect-compete.html closes the popup window and
    # invokes your js callback. Params appended to this url will be passed to
    # the callback.
    redirect_to "/sc-connect-complete.html?username=#{CGI::escape(me.username)}"
  end

end
