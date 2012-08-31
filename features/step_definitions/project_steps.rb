Then /^(.*) contest page should not contain any information about "([^"]*)" project$/ do |contest_name, project_name|
  visit(contest_path(Contest.find_by_name!(contest_name)))
  find('h2').should have_content(contest_name)
  page.should have_no_content(project_name)

end
