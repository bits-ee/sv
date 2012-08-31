require 'open-uri'
#require 'net/https'
class UsersController < ApplicationController

  before_filter :check_login, :only => [:edit, :update, :logout, :index, :toggle]
  before_filter :check_admin, :only => [:toggle]
  force_ssl_with_params_fix

  def index
    redirect_to root_path and return unless current_user.is_priority?
  end

  def login
    if request.post?
      @user = User.find_by_email_and_user_type(params[:email].strip, [User.type_regular, User.type_priority])
      if params[:email].strip.length > 0 && @user && @user.password_digest.present? && @user.authenticate(params[:password].strip)
        flash.now[:error] = t('user.access_denied') and return if [User.status_disabled, User.status_invited].include? @user.status
        session[:user_id] = @user.id
        @user.update_attribute(:last_login_date, Time.now)
        I18n.locale = @user.locale
        redirect_to (params[:redirect].blank? ? (@user.is_admin? ? dashboard_path : root_path) : params[:redirect])
      else
        flash.now[:error] = t('user.wrong_credentials')
      end
    else
      redirect_to root_path if user_logged_in?
    end
  end

  def forgot_password
    reset_session if user_logged_in?
    if request.post?
      if !params[:email].blank? and params[:email].match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i)
        user = User.find_by_email_and_status(params[:email].strip, User.status_active)
        if user
          user.generate_reset_token
          if user.save
            Notifier.reset_password_instructions(user).deliver
            redirect_to login_users_path, :flash => {:notice => t('user.reset_mail_sent', :email => user.email)} and return
          else
            flash[:error] = user.errors.full_messages.join('.<br>').html_safe
          end
        else
          flash[:error] = t('user.forgot_password.user_not_found')
        end
      else
        flash[:error] = t('user.forgot_password.invalid_email')
      end
    end
  end

  def reset_password
    reset_session if user_logged_in?
    redirect_to login_users_path, :flash => {:error => t('common.invalid_params')} and return if params[:email].blank? or params[:reset_token].blank?
    @user = User.find_by_email_and_status_and_reset_token(params[:email], User.status_active, params[:reset_token])
    redirect_to login_users_path, :flash => {:error => t('common.invalid_params')} and return unless @user
    if request.post?
      @user.reset_password = params[:reset_token]
      if @user.update_attributes(params[:user])
        @user.update_attribute(:reset_token, nil)#delete password reset token
        redirect_to login_users_path, :flash => {:notice => t('user.password_changed')}
      else
        flash[:error] = @user.errors.full_messages.join('.<br>').html_safe
      end
    end
  end

  def new
    reset_session if params[:email] and params[:invite_token]
    if !user_logged_in?
      @user, @project = User.find_invited_user_and_project(params[:email], params[:invite_token]) if params[:email] and params[:invite_token]
      unless @user
        flash[:error] = t('user.invitation.not_found', :email => params[:email].strip) if params[:email]
        #registration form for regular user
        @user = User.new
        @user.user_type = User.type_regular
        @user.locale = I18n.locale.to_s
      end
    elsif current_user and current_user.is_admin?
      #admin adds new priority user or lector
      @user = User.new
      @user.user_type = (params[User.type_lector.downcase]) ? User.type_lector : User.type_priority
    else
      redirect_to root_path, :flash => {:error => t('user.access_denied')}
    end
  end

  def create

    if !user_logged_in?
      #user registers itself with its project or registers itself by invitation
      if params[:user][:email] and params[:user][:invite_token]
        #user with invitation
        @user, @project = User.find_invited_user_and_project(params[:user][:email], params[:user][:invite_token])
        if @user.nil?
          redirect_to root_path, :flash => {:error => t('user.access_denied')} and return
        else
          #activate and authenticate user
          ActiveRecord::Base.transaction do
            @user.status = User.status_active
            raise unless @user.update_attributes(params[:user])
            @user.update_attributes(:last_login_date => Time.now, :updated_by => @user.id, :locale => I18n.locale)
            session[:user_id] = @user.id
          end
          Notifier.welcome(@user).deliver
          redirect_to root_path, :flash => {:notice => t('user.welcome', :fullname => @user.fullname)} and return
        end
      else
        #no invite code was found, just a new user/project registration
        @project = Project.new(params[:project])
        @user = User.new(params[:user])
        ActiveRecord::Base.transaction do
          #checks if user with specified email address was already invited by any project
          invited_user = User.find_by_email_and_status_and_user_type(params[:user][:email].strip, User.status_invited, User.type_regular)
          raise t('user.invitation.already_invited', {:email => params[:user][:email].strip, :project => invited_user.project.name}) if invited_user

          #tries to create new project and its first user
          #first lets look for available third party authorizations
          @auth = Authentication.find_by_provider_and_uid_and_user_id(session['auth_provider'], session['auth_uid'], nil) if third_party_authorized
          # user doesn't need to specify a password, if third party authorization was found
          if @auth.present?
            @user.auth_id = @auth.id
            if @auth.image_url
              begin
                uri = URI.parse(@auth.image_url)
                io = open(uri, 'rb')
                original_filename = File.basename(uri.path)
                io.original_filename = original_filename.match(/^.+\.\w{1,4}$/) ? original_filename : io.original_filename
                @user.avatar = io
              rescue
                flash[:warning] = t('user.third_party_cant_add_avatar')
              end
            end
          end
          @project.status = Project.status_draft
          raise unless @project.save
          @user.project_id = @project.id
          @user.status = User.status_active
          @user.user_type = User.type_regular
          @user.locale = I18n.locale
          raise unless @user.save
          @project.update_attributes(:created_by => @user.id, :updated_by => @user.id)
          @user.update_attributes(:last_login_date => Time.now, :created_by => @user.id, :updated_by => @user.id)
          if @auth.present?
            @auth.user_id = @user.id
            @auth.save!
          end
          session.delete('auth_provider')
          session.delete('auth_uid')
          #authorizes new user
          session[:user_id] = @user.id
        end
        session[:track_new_project_event] = true if Rails.env.production?
        Notifier.welcome(@user).deliver
        redirect_to edit_project_path(@project.id), :flash => {:notice => "#{t('user.welcome', :fullname => @user.fullname)}<br>#{t('project.registered', :name => @project.name)}".html_safe}
      end

    elsif current_user.is_regular?
      #current regular user invites somebody to participate in his project
      @user = User.new(params[:user])
      invite_regular_user current_user.project_id
      render 'projects/edit' and return

    elsif current_user.is_admin?

      @user = User.new(params[:user].reject{|k, v| k == 'user_type'})

      if params[:user][:user_type] == User.type_lector
        #current user, who is an administrator, adds new lector
        @user.status = User.status_active
        @user.user_type = User.type_lector
        @user.created_by=current_user_id
        #@user.password = @user.password_confirmation = @user.fullname #because model always requires password
        if @user.save
          redirect_to edit_user_path(@user), :flash => {:notice => t('user.added_lector', :fullname => @user.fullname)}
        else
          flash[:error] = @user.errors.full_messages.join('.<br>').html_safe
          render 'new' and return
        end
      elsif params[:user][:user_type] == User.type_priority
        #current user, who is an administrator, invites somebody from Open Priority to become a site user
        @user.status = User.status_invited
        @user.user_type = User.type_priority
        @user.created_by = current_user_id
        @user.password = @user.password_confirmation = @user.fullname #because model always requires password
        if @user.save
          Notifier.notify_invited_user(@user).deliver
          redirect_to edit_user_path(@user), :flash => {:notice => t('user.invitation.invited', :fullname => @user.fullname)} and return
        else
          flash[:error] = @user.errors.full_messages.join('.<br>').html_safe
          render 'new' and return
        end
      else
        redirect_to root_url, :flash => {:error => t('user.access_denied')} and return
      #elsif params[:user][:project_id]
      #  #current user, who is an administrator, invites somebody to become a participant of specified project
      #  invite_regular_user params[:user][:project_id].to_i
      #  render 'projects/edit' and return
      end
    else
      redirect_to root_url, :flash => {:error => t('user.access_denied')}
    end

  rescue Exception => e
    #raise e
    validation_errors = ((@project.present? ? @project.errors.full_messages : []) + (@user.present? ? @user.errors.full_messages : [])).join('. ')
    flash[:error] = validation_errors.length > 0 ? validation_errors : (raise e)
    render 'new'
    return
  end

  def update
    redirect_to edit_user_path(current_user_id) and return unless can_edit_user? params[:id].to_i
    @user = User.find(params[:id])
    if params[:user]
      params[:user][:twitter] = params[:user][:twitter].gsub(t('support.twitter_baseurl'), '') if params[:user][:twitter]

      if params[:user][:current_password]  #user's password changing
        redirect_to root_url, :flash => {:error => t('user.access_denied')} and return if @user.password_digest.blank?
        #current_password is under mass-assignment protection
        @user.current_password = params[:user][:current_password]
        msg = t('user.password_changed')
      else
        msg = t('common.ok')
      end
      if current_user.is_owner_of_public_project? @user.project and (params[:user].symbolize_keys.keys & @user.public_fields).size > 0
        redirect_to root_url, :flash => {:error => t('user.access_denied')}
        return
      end
      @user.update_attributes(params[:user].merge :updated_by => current_user_id)
    end

    if @user.errors.empty?
      flash[:notice] = msg
      ##reset new password attributes, we don't want to show them on a form
      #@user = User.find(current_user_id)
      redirect_to user_path @user.id
    else
      flash[:error] = @user.errors.full_messages.join('.<br>').html_safe
      render 'edit'
    end

  end

  def show
    unless can_view_user? params[:id].to_i
      try_login_or_redirect_to_root
      return
    end
    @user = User.find(params[:id])
    redirect_to user_path(current_user_id) and return if @user.is_disabled?
  rescue
    redirect_to root_path, :flash => {:error => t('user.access_denied')}
  end

  def edit
    try_login_or_redirect_to_root and return unless can_edit_user? params[:id].to_i
    @user = User.find(params[:id])
  rescue
    redirect_to root_path, :flash => {:error => t('user.access_denied')}
  end

  def toggle
    user = User.find(params[:id])
    raise if user.nil?
    status = params[:status].to_i
    if status == 0 and (user.is_active? or user.is_invited?) #disable
      raise if user.id == current_user_id #cant disable yourself
      raise unless user.update_attribute(:status, User.status_disabled)
    elsif status == 1 and user.is_disabled? #activate
      if user.invite_token.nil?
        raise unless user.update_attribute(:status, User.status_active)
      else
        raise unless user.update_attribute(:status, User.status_invited)
      end
    else
      raise
    end
    redirect_to :back, :flash => {:notice => t('common.saved')}
  rescue Exception => e
    #raise e
    redirect_to root_path, :flash => {:error => t('user.access_denied')}
  end

  private
    def invite_regular_user(project_id)
      #current user invites somebody to participate in specified project
      @user.status = User.status_invited
      @user.user_type = User.type_regular
      @user.project_id = project_id
      @user.created_by=current_user_id
      @user.password = @user.password_confirmation = @user.fullname #because model always requires password
      @project = Project.find(project_id)
      if @project and @user.save
        Notifier.notify_invited_user(@user).deliver
        flash[:notice] = t('user.invitation.invited', :fullname => @user.fullname)
        @user = User.new
      else
        flash[:error] = @user.errors.full_messages.join('.<br>').html_safe
      end

    end
end
