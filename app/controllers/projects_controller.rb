class ProjectsController < ApplicationController

  before_filter :check_login, :only => [:edit, :update, :index]
  before_filter :check_admin, :only => [:destroy]

  force_ssl_with_params_fix :except => :show
  before_filter :secure_current_user, :only => :show

  def index
    redirect_to root_path and return unless current_user.is_priority?
    @contest = Contest.order('id desc').includes(:projects).first
    @projects = @contest.projects.includes(:user)
  end

  def update
    @project = Project.find(params[:id])
    redirect_to root_path and return unless can_change_project? @project

    params['project']['url'] = nice_url(params['project']['url']) if params['project']['url']

    if current_user.is_admin? and params["project"]["status"] and Project.change_status_rules[@project.status].include? params["project"]["status"]
      #admin asks project founder to add more detailed description to the project
      @project.status = params["project"]["status"]
      @project.skip_validation = true
      status_changed_by_admin = true
      if params["project"]["status"] == Project.status_rejected
        Notifier.notify_user_about_project_status_change(@project, params["reason"].strip, ).deliver
      end
    elsif current_user.is_regular? and current_user.project_id == @project.id
      if current_user.is_owner_of_public_project? @project and (params[:project].symbolize_keys.keys & @project.public_fields).size > 0
        redirect_to root_url, :flash => {:error => t('user.access_denied')}
        return
      end
      if params["commit"] == t('project.publish_project.button')
        if @project.is_draft?
          project_was_added_or_resubmitted = true
          @project.status = Project.status_added
        elsif @project.is_rejected?
          project_was_added_or_resubmitted = true
          @project.status = Project.status_resubmitted
        end
      end
    end
    if @project.update_attributes(params[:project].merge :updated_by => current_user_id)
      flash[:notice] = t('common.saved')
      if status_changed_by_admin
        User.admins_to_notify.reject{|admin| admin.id == current_user_id}.each do |admin|
          Notifier.notify_admin_about_project_status_change(@project, admin).deliver
        end
      end
      if current_user_id == @project.user.id
        if project_was_added_or_resubmitted and @project.is_waiting_for_moderation?
          User.admins_to_notify.each do |admin|
            Notifier.notify_admin_about_new_project_added(@project, admin).deliver
          end
        elsif @project.is_public?
          User.admins_to_notify.each do |admin|
            Notifier.notify_admin_about_changes_in_public_project(@project, admin).deliver
          end
        end
      end
      # отвечаем на жс
      respond_to do |format|
        format.html { redirect_to project_path(@project.id) }
        format.json { render json: @project }
      end
    else
      flash[:error] = @project.errors.full_messages.join('.<br>').html_safe
      # отвечаем на жс
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @project.errors, :status => :unprocessable_entity }
      end
    end
  rescue
    raise
    redirect_to root_path, :flash => {:error => t('user.access_denied')}
  end

  def edit
    @project = Project.find(params[:id])
    try_login_or_redirect_to_root and return unless can_change_project? @project

    if session[:track_new_project_event]
      @track_new_project_event = true
      session[:track_new_project_event] = nil
    end

  rescue
    redirect_to root_path, :flash => {:error => t('user.access_denied')}
  end

  def show
    @project = Project.find(params[:id])
    try_login_or_redirect_to_root and return unless can_view_project? @project
  rescue
    redirect_to root_path, :flash => {:error => t('user.access_denied')}
  end


  def destroy
    redirect_to root_path, :flash => {:error => t('user.access_denied')} unless can_delete_project?
    project = Project.find(params[:id]).destroy
    redirect_to projects_path, :flash => {:notice => t('project.deleted', :name => project.name)}
  end



end