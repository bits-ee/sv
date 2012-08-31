
When /^a new site visitor, opens sign up form, fills it with following data and submits form:$/ do |signup_data|
  signup_data.hashes.each do |hash|
    signup(hash['project name'], hash['name'], hash['email'], hash['password'], hash['password_confirmation'])
  end
end


When /^(.*) logs in$/ do |user_name|
  user = User.find_by_name!(user_name)
  login(user.email, PASSWORD_STUB)
end

When /^he logs in with "(.*)" and "(.*)"$/ do |email, password|
  login(email, password)
end

When /^(.*) asks for password reset instruction$/ do |user_name|
  user = User.find_by_name!(user_name)
  visit(login_users_path)
  within('form#login_form') do
    click_link_or_button(t('user.forgot_password.title'))
  end
  within('form#forgot_password_form') do
    fill_in(User.human_attribute_name(:email), :with => user.email)
    click_button(t('user.get_new_password'))
  end
end

When /^(.*) sets new password "([^"]*)" using mail instructions$/ do |user_name, new_password|
  user = User.find_by_name!(user_name)
  visit(check_mail(user, 'password reset instructions'))
  within("form#{'#' + 'edit_user_' + user.id.to_s}") do
    fill_in(User.human_attribute_name(:new_password), :with => new_password)
    fill_in(User.human_attribute_name(:password_confirmation), :with => new_password)
    click_button(t('user.profile.change_password'))
  end


end


When /^(.*) changes his password for "([^"]*)"$/ do |user_name, new_password|
  user = User.find_by_name!(user_name)
  visit(edit_user_path(user))
  fill_in(User.human_attribute_name(:current_password), :with => PASSWORD_STUB)
  fill_in(User.human_attribute_name(:new_password), :with => new_password)
  fill_in(User.human_attribute_name(:password_confirmation), :with => new_password)
  click_button(t('user.profile.change_password'))

end


When /^he invites new priority user with email "([^"]*)"$/ do |email|
  within('#links') do
    click_link(t('user.users'))
  end
  click_link(t('user.add_priority_user'))
  within('form#new_user') do
    fill_in(User.human_attribute_name(:email), :with => email)
    click_button(t('user.add'))
  end
end

When /^(.*) accepts an invitation$/ do |email|
  user = User.find_by_email!(email)
  visit(check_mail(user, 'invitation'))
  within("form") do
    fill_in(User.human_attribute_name(:password), :with => PASSWORD_STUB)
    fill_in(User.human_attribute_name(:password_confirmation), :with =>  PASSWORD_STUB)
    click_button(t('common.signup'))
  end
end


When /^blocks regular user (.*)$/ do |user_name|
  user = User.find_by_name!(user_name)
  visit(edit_user_path(user))
  click_link_or_button(t('user.status_todo.disable'))
end

Then /^(.*) cant login$/ do |user_name|
  user = User.find_by_name!(user_name)
  login(user.email, PASSWORD_STUB)
  current_path.should == login_users_path
end


When /^he adds new lector with a name of "([^"]*)"$/ do |lector_name|
  visit(users_path(:user_type => 'lector'))
  click_link(t('user.add_lector'))
  fill_in(User.human_attribute_name(:name), :with => lector_name)
  click_button(t('user.add_lector'))
end

When /^he logs out$/ do
  click_link(t('user.logout'))
end

Then /^he should stay on login page$/ do
  current_path.should == login_users_path
end

Then /^(.*), as an? (regular user|priority user|admin), should see his info in user panel$/ do |name_or_email, user_type|
  user = find_user_by_name_or_email name_or_email
  find('#links ul li a.with-image span').should have_content(user.fullname)
  if user_type == 'regular user'
    find('#links ul li:first-child+li a.with-image span').should have_content(user.project.name)
  elsif user_type == 'admin'
    find('#links ul li a.with-image span').should have_content("(#{User.human_attribute_name(:is_admin)})")
  end
end

Then /^(.*) should be redirected to his project edit page$/ do |user_name|
  user = User.find_by_name!(user_name)
  current_path.should == edit_project_path(user.project)
end

Then /^lectors page should contain info about (.*)$/ do |lector_name|
  visit(users_path(:user_type => 'lector'))
  current_url.should == users_url(user_type: 'lector', protocol: 'https://')
  page.should have_content(lector_name)
end

