Before do
  app.default_url_options = { :locale => I18n.locale }
end

Then /^(.*) should receive an? (.*) mail$/ do |name_or_email, mail_type|
  user = find_user_by_name_or_email name_or_email
  check_mail(user, mail_type)
end

Then /^he should see an (error|notice) message about (.*)$/ do |msg_type, message_name|
  case message_name
    when 'wrong credentials'
      message_text = t('user.wrong_credentials')
    when 'access denied'
      message_text = t('user.access_denied')
    else
      raise 'unknown message name: ' + message_name
  end
  find("#status-top .messages .#{msg_type}").should have_content(message_text)
end


When /^opens contest page$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^show me the page$/ do
  save_and_open_page
end

#Given /^the following users:$/ do |users|
#  User.create!(users.hashes)
#end
#
#When /^I delete the (\d+)(?:st|nd|rd|th) user$/ do |pos|
#  visit users_path
#  within("table tr:nth-child(#{pos.to_i+1})") do
#    click_link "Destroy"
#  end
#end
#
#Then /^I should see the following users:$/ do |expected_users_table|
#  expected_users_table.diff!(tableish('table tr', 'td,th'))
#end
