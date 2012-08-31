class PagesController < ApplicationController
  
  before_filter :check_admin, :only => [:dashboard]
  before_filter :secure_current_user, :except => :dashboard
  force_ssl_with_params_fix :only => :dashboard

  def main
    contest = Contest.order('id desc').first
    raise 'no contest found' unless contest
    
    if I18n.locale.to_s == 'en'
      @contest_name = contest.name_en
    elsif I18n.locale.to_s == 'es'
      @contest_name = contest.name_es
    else
      @contest_name = contest.name
    end
    @contest_id = contest.id
    
    @projects = Project.where(contest_id: contest.id).public_scope.all.sort{rand-0.5}
    @show_link = @projects.length > 8
    @projects = @projects[0..7]
    while ((@projects.length % 8 != 0) or @projects.length == 0) do
      @projects << Project.new(name: t('project.your_project_name'), synopsys: t('project.your_project_synopsys'))
    end
    
    render layout: 'application'
  end
  
  def who
    @orgs = User.where(:group => 1, :status => User.status_active).order(:group_order_number).all
    @admins = User.where(:group => 2, :status => User.status_active).order(:group_order_number).all #
    @lectors = User.where(:group => 3, :status => User.status_active).order(:group_order_number).all #
    @mentors = User.where(:group => 4, :status => User.status_active).order(:group_order_number).all #
    @guests = User.where(:group => 5, :status => User.status_active).order(:group_order_number).all #
    @alumnis = User.where(:group => 6, :status => User.status_active).order(:group_order_number).all #
  end
  
  def season2011
    if params[:record].to_i > 0
      render "pages/blog2011/#{params[:record].to_i}" and return
    end
  end
  
  def dashboard
    
  end

end