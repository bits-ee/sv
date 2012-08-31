Feature: Project publishing
  In order to win a contest
  As a regular user
  I want to prepare my project for publishing, publish it and change its description if needed

  Background: A contest was started
    Given a contest exists with a name of "Spring 2011"

  Scenario: User registers itself and his new project, but the project is not published yet
    When a new site visitor, opens sign up form, fills it with following data and submits form:
      | project name    | name   | email            | password    | password_confirmation |
      | BillDollarsIdea | Zahhar | zahhar@gmail.com | secure_pass | secure_pass           |
    And he logs out
    Then Spring 2011 contest page should not contain any information about "BillDollarsIdea" project
