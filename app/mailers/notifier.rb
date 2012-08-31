class Notifier < ActionMailer::Base
  default :from => I18n::translate('mail.info_email')

  def t(key, options={})
    I18n::translate(key, options)
  end

  def welcome(user)
    @user = user
    @title = "#{t('support.shortname')}: #{t('mail.title.user_registration')}."
    mail(:to => get_name, :subject => @title)
  end

  def notify_invited_user(user)
    @user = user
    @title = "#{t('support.shortname')}: #{t('mail.title.you_are_invited')}."
    mail(:to => get_name, :subject => @title)
  end

  def reset_password_instructions(user)
    @user = user
    within_locale(@user.locale) do
      @title = "#{t('support.shortname')}: #{t('mail.title.password_reset_instructions')}."
      mail(:to => get_name, :subject => @title)
    end
  end

  def notify_user_about_project_status_change(project, reason=nil)
    @project = project
    @user = project.user
    @reason = reason
    within_locale(@user.locale) do
      @title = "#{t('support.shortname')}: #{t('mail.title.project_status_change')}."
      mail(:to => get_name, :subject => @title)
    end
  end

  def notify_admin_about_new_project_added(project, admin_user)
    @user = admin_user
    @project = project
    within_locale(@user.locale) do
      @title = "#{t('support.shortname')}: #{t('mail.title.new_project_added')} #{@project.name.truncate(20)}."
      mail(:to => get_name, :subject => @title)
    end

  end

  def notify_admin_about_changes_in_public_project(project, admin_user)
    @user = admin_user
    @project = project
    within_locale(@user.locale) do
      @title = "#{t('support.shortname')}: #{t('mail.title.public_project_changed')} #{@project.name.truncate(20)}."
      mail(:to => get_name, :subject => @title)
    end
  end

  def notify_admin_about_project_status_change(project, admin_user)
    @user = admin_user
    @project = project
    within_locale(@user.locale) do
      @title = "#{t('support.shortname')}: #{t('mail.title.project_status_change')} #{@project.name.truncate(20)}."
      mail(:to => get_name, :subject => @title)
    end
  end

  private
    def get_name
      "#{@user.fullname} <#{@user.email}>"
    end

    def within_locale(locale)
      orig_locale = I18n.locale
      I18n.locale = locale.blank? ? I18n.locale : locale
      yield
      I18n.locale = orig_locale
    end
end
