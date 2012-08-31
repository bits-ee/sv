THIRD_PARTY_AUTH = ['google_oauth2', 'facebook', 'vkontakte'].freeze

FB_APP_ID = '316061828446302'.freeze
FB_APP_SECRET = '3c7522687bd5ee4b52fa6b357b2ab7fd'.freeze
FB_SCOPE = 'email,offline_access,read_stream'.freeze

GOOGLE_APP_ID = '222267407348.apps.googleusercontent.com'.freeze
GOOGLE_APP_SECRET = 'nRNeGMV4yZaSrjTn6MCWFgK7'.freeze
GOOGLE_SCOPE = 'https://www.googleapis.com/auth/userinfo.email,https://www.googleapis.com/auth/userinfo.profile,https://www.googleapis.com/auth/plus.me'.freeze

VKONTAKTE_APP_ID = '2793466'.freeze
VKONTAKTE_APP_SECRET = 'TNPWF04PihBSdxxGXQIy'.freeze
#VKONTAKTE_SCOPE = 'https://www.googleapis.com/auth/userinfo.email,https://www.googleapis.com/auth/userinfo.profile'.freeze

Rails.application.config.middleware.use OmniAuth::Builder do

  #provider :openid, OpenID::Store::Filesystem.new('./tmp'), :name => 'google', :identifier => 'https://www.google.com/accounts/o8/id
  #provider :twitter, 'AR9jefJsDK7TNqdNEc0yA', '8sd8fqLzCOFzM6uoRvk3sWLYoKpbhlSHtGM8mUce0Q'

  provider :facebook, FB_APP_ID, FB_APP_SECRET, { :client_options => {:ssl => {:ca_file => "#{Rails.root}/config/ca-bundle.crt"}} }
  provider :google_oauth2, GOOGLE_APP_ID, GOOGLE_APP_SECRET, {access_type: 'online', approval_prompt: 'auto'}
  #provider :google_oauth2, '651219949435.apps.googleusercontent.com', 'o5Ca1zDUGwWKmFrnqNwhMiYu', { :scope => 'https://www.googleapis.com/auth/plus.me', :client_options => {:ssl => {:ca_file => "#{Rails.root}/config/ca-bundle.crt"}} }

  provider :vkontakte, VKONTAKTE_APP_ID, VKONTAKTE_APP_SECRET
end