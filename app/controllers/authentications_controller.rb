class AuthenticationsController < ApplicationController

  after_filter :clear_session, :only => [:create]
  force_ssl_with_params_fix

  def clear_session
    session.delete :user_locale
  end

  def index
    session[:user_locale] = params[:locale] ? params[:locale] : I18n.locale
    redirect_to auth_path(params[:provider], locale: nil)
  end

  def create

    service_provider = params[:provider]
    omniauth = request.env['omniauth.auth']

    #__debug request.env['omniauth.auth'].inspect
    return unless THIRD_PARTY_AUTH.include? service_provider

    if omniauth and service_provider
      auth_hash = {}
      auth_hash[:provider]  = omniauth['provider']
      auth_hash[:uid]       = omniauth['uid']
      auth_hash[:image_url]  = omniauth['provider'] == 'vkontakte' ? omniauth['extra']['raw_info']['photo_big'] : omniauth['info']['image']
      auth_hash[:profile_url] =
        case service_provider
          when 'facebook'
            omniauth['info']['urls']['Facebook']
          when 'google_oauth2'
            omniauth['extra']['raw_info']['link']
          when 'vkontakte'
            omniauth['info']['urls']['Vkontakte']
          else
            raise 'unknown oauth2 provider'
        end

      user_hash = {}
      user_hash[:email]     = omniauth['info']['email']
      user_hash[:name]      = omniauth['info']['name']
    end
    user_locale = session['user_locale'] ? session['user_locale'] : I18n.locale
    if auth_hash[:provider] != '' and auth_hash[:uid] != ''
      @auth = Authentication.find_by_provider_and_uid(auth_hash[:provider], auth_hash[:uid])
      if user_logged_in?
        reset_session
        redirect_to root_path, :flash => {:notice => t('user.logout_notice')} and return
      else
        if @auth and @auth.user_id.present?
          # existed user was found, just login
          redirect_to root_path, :flash => {:error => t('user.access_denied')} and return if [User.status_disabled, User.status_invited].include? @auth.user.status
          session[:user_id] = @auth.user.id
          I18n.locale = @auth.user.locale
          @auth.user.update_attribute(:last_login_date, Time.now)
        else
          @user = User.new(user_hash)
          @user.user_type = User.type_regular
          @auth = Authentication.create!(auth_hash) unless @auth
          session['auth_provider'] = @auth.provider
          session['auth_uid'] = @auth.uid
          I18n.locale = user_locale
          render('users/new') and return
        end
      end
    end
    redirect_to root_path()
  end

  def failure
    user_locale = session[:user_locale] ? session[:user_locale] : I18n.locale
    reset_session
    I18n.locale = user_locale
    case params['message']
      when 'invalid_credentials'
        #flash[:error] = t('user.third_party_invalid_credentials', locale: locale) + ' ' + t('user.third_party_error', locale: locale)
        flash[:error] = t('user.third_party_error')
      else
        flash[:error] = t('user.third_party_error')
    end
    redirect_to root_path()
  end

  def destroy
    auth = Authentication.find_by_provider_and_uid_and_user_id(params[:provider], params[:uid], nil)
    reset_session
    if auth #if user clicks Cancel on sign up form after authenticating with social network
      auth.delete
      redirect_to signup_path
    else  #user just logs out
      redirect_to root_url(:protocol => 'http'), :flash => {:notice => t('user.logout_notice')}
    end
  end

end
