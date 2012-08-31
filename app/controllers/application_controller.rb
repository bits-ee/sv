class ApplicationController < ActionController::Base

  protect_from_forgery
  helper_method :current_user, :user_logged_in?, :current_user_id, :can_change_project?, :can_view_project?, :can_edit_user?, :can_view_user?, :third_party_authorized, :can_delete_project?
  before_filter :set_locale, :check_deadline

  def set_locale
    available = %w{en es ru}
    if available.include?(params[:locale])
      I18n.locale = params[:locale]
    else
      I18n.locale = request.preferred_language_from(available) #I18n.default_locale
    end
  end
  
  def check_deadline
    deadline = Contest.order('id desc').first.deadline
    @distance = (deadline-Date.today).to_i
    
    if @distance > 0
      @notification = t('common.deadline', :date => "#{l(deadline)}", :distance => "#{t('datetime.distance_in_words.x_days', :count => @distance)}").html_safe
    elsif @distance == 0
      @notification = t('common.deadline_today')
    else 
      @notification = nil#t('common.deadline_overdue')
    end
    
  end

  def default_url_options
    {:locale => I18n.locale}
  end

  def check_login
    if user_logged_in?
      return true
    else
      try_login_and_redirect_back
    end
  end

  def third_party_authorized
    session['auth_provider'] and session['auth_uid']
  end

  #if user clicks on a link for page, which he can't see
  def try_login_or_redirect_to_root
    redirect_to root_path and return if user_logged_in? #logged in user tries to access page, which he should not see.
    try_login_and_redirect_back
  end

  def check_admin
    if user_logged_in? and current_user.is_admin?
      return true
    else
      redirect_to root_path
    end
  end

  def can_edit_user? (user_id)
    (current_user and current_user.is_admin?) or user_id == current_user_id
  end

  def can_view_user? (user_id)
    (current_user and current_user.is_priority?) or user_id == current_user_id
  end

  def can_change_project?(project)
    current_user and (current_user.is_admin? or current_user.project_id == project.id)
  end

  def can_view_project?(project)
    project.is_public? or (current_user and (current_user.is_priority? or current_user.project_id == project.id))
  end

  def can_delete_project?
    current_user and current_user.is_admin?
  end

  def user_logged_in?
    current_user.nil? ? false : true
  end

  def current_user
    @current_user ||= get_valid_current_user
  end

  def current_user_id
    current_user.nil? ? nil : current_user.id
  end

  def nice_url(url)
    url.strip!
    unless url.blank?
      url.sub!(/\/$/,'') # remove trailing slash
      url = "http://#{url}" unless url.match(/https?:\/\/.*$/i) # add http:// if omitted
      begin
        if url.length > 30 or url.include? '?' #shorten long or parameterized urls
          ggl = Shortly::Clients::Googl
          ggl.apiKey = 'AIzaSyCuCdoIrfMEt5kBOEbe5IinKiEn7Aptvo0' #connected to SpanishVillage project under zahhar@gmail.com account
          url = ggl.shorten(url).shortUrl
        end
      rescue
        return url
      end
    end

    url
  end

  def secure_current_user
    #if user, being logged in, clicks on a link to spanish village website, which doesn't contain https protocol (eg. from IM, mail, on any other website)
    redirect_to({:protocol => 'https://'}.merge! request.query_parameters) if current_user.present? and !request_with_ssl?
  end

  def request_with_ssl?
    #we do not work behind ssl in development
    Rails.env.development? or request.ssl?
  end

  #replace all this method usages with force_ssl after upgrading to rails 3.2.2
  #basically this is a FORCE_SSL method of Rails, with query params fix, which rails 3.2.1 doesn't contain yet
  def self.force_ssl_with_params_fix(options = {})
    host = options.delete(:host)
    before_filter(options) do
      if !request.ssl? && !Rails.env.development?
        redirect_options = {:protocol => 'https://', :status => :moved_permanently}
        redirect_options.merge!(:host => host) if host
        redirect_options.merge! request.query_parameters
        redirect_to redirect_options
      end
    end
  end

  private

    def try_login_and_redirect_back
      redirect_path = request.env['REQUEST_URI'] =~ /^\/(en|ru|es)?\/?$/ ? nil : request.env['REQUEST_URI']
      reset_session
      options = redirect_path.nil? ? {} : {:redirect => redirect_path}
      options.merge! :protocol => 'https://' if Rails.env.production?
      redirect_to login_users_path(options)
    end

    def get_valid_current_user
      return nil unless session[:user_id]
      user = User.find(session[:user_id])
      if user.status == User.status_disabled
        reset_session
        nil
      else
        user
      end
    end
end
