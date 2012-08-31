# include default factory girl step definitions
require 'factory_girl/step_definitions'

#Usage of default factory_girl step definitions:
#
#Given a user exists
#
#Given the following recruiter exists:
# | email            | phone number | employer name |
# | bill@example.com | 1234567890   | thoughtbot    |
#
#Given 2 users exist
#
#Given a user exists with an email of "author@example.com"
#
#Given 2 users exist with an email of "author@example.com"




def t(key, options={})
  I18n::translate(key, options)
end

module StepHelpers
  def find_user_by_name_or_email name_or_email
    match_data = name_or_email.match /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
    if match_data.present? 
      user = User.find_by_email!(match_data[0])
    else
      user = User.find_by_name!(name_or_email)
    end
  end

  def login(email, password)
    visit(login_users_path)
    within('form#login_form') do
      fill_in(User.human_attribute_name(:email), :with => email)
      fill_in(User.human_attribute_name(:password), :with => password)
      click_button(t('user.enter'))
    end
  end

  def signup(project_name, user_name, email, password, password_confirmation)
    visit(signup_path)
    within('form#new_user') do
      fill_in(Project.human_attribute_name(:name), :with => project_name)
      fill_in(User.human_attribute_name(:name), :with => user_name)
      fill_in(User.human_attribute_name(:email), :with => email)
      fill_in(User.human_attribute_name(:password), :with => password)
      fill_in(User.human_attribute_name(:password_confirmation), :with => password_confirmation)
      click_button(t('common.signup'))
    end
  end
end

World(StepHelpers)

module MailSteps
  def check_mail(user, mail_type)
    case mail_type
    when 'welcome'
      ActionMailer::Base.deliveries.each do |mail|
        if mail.to.include? user.email
          mail.subject.should include t('mail.title.user_registration')
          return
        end
      end
    when 'password reset instructions'
      ActionMailer::Base.deliveries.each do |mail|
        if mail.to.include? user.email
          mail.subject.should include t('mail.title.password_reset_instructions')
          return mail.body.match(/\/reset_password\S*reset_token=\w{16}/)[0]
        end
      end
    when 'invitation'
      ActionMailer::Base.deliveries.each do |mail|
        if mail.to.include? user.email
          mail.subject.should include t('mail.title.you_are_invited')
          return mail.body.match(/\/signup\S*invite_token=\w{16}/)[0]
        end
      end
    when t('mail.title.project_status_change')
      raise 'not implemented'
    when t('mail.title.new_project_added')
      raise 'not implemented'
    when t('mail.title.public_project_changed')
      raise 'not implemented'
    else
      raise 'wrong mail type: ' + mail_type 
    end

    raise 'mail was not found'

  end
end

World(MailSteps)