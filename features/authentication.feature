Feature: User login
  In order to apply for a contest
  As a regular user
  I want to register and get access to private section, to be able to change password and all that stuff

  Background: A contest was started
    Given a contest exists

  Scenario: User registers itself and his new project
    When a new site visitor, opens sign up form, fills it with following data and submits form:
      | project name    | name   | email            | password    | password_confirmation |
      | BillDollarsIdea | Zahhar | zahhar@gmail.com | secure_pass | secure_pass           |
    Then Zahhar should be redirected to his project edit page
    And Zahhar, as a regular user, should see his info in user panel
    And Zahhar should receive a welcome mail

  Scenario: User tries to login with a wrong password
    Given a regular user exists with an email of "zahhar@gmail.com"
    When he logs in with "zahhar@gmail.com" and "wrong_password"
    Then he should stay on login page
    And he should see an error message about wrong credentials

  Scenario: User is greeted upon login
    Given a regular user exists with a name of "Zahhar"
    When Zahhar logs in
    Then Zahhar, as a regular user, should see his info in user panel

  Scenario: User forgot his password and retrieves it with instructions sent by email
    Given the following regular user exists:
      | name   | email            |
      | Zahhar | zahhar@gmail.com |
    When Zahhar asks for password reset instruction
    Then Zahhar should receive a password reset instructions mail
    When Zahhar sets new password "new_pass" using mail instructions
    And he logs in with "zahhar@gmail.com" and "new_pass"
    Then Zahhar, as a regular user, should see his info in user panel

  Scenario:  User wants to change his password
    Given the following regular user exists:
      | name   | email            |
      | Zahhar | zahhar@gmail.com |
    When Zahhar logs in
    And Zahhar changes his password for "new_password"
    And he logs out
    And he logs in with "zahhar@gmail.com" and "new_password"
    Then Zahhar, as a regular user, should see his info in user panel
  
  Scenario: Admin blocks regular user, not allowing him to login
    Given a regular user exists with a name of "Andrei"
    And an admin exists with a name of "Zahhar"
    When Zahhar logs in
    And blocks regular user Andrei
    And he logs out
    Then Andrei cant login
    And he should see an error message about access denied

  Scenario: Admin invites new priority user, who accepts an invitation
    Given an admin exists with a name of "Zahhar"
    When Zahhar logs in
    And he invites new priority user with email "andrei.filimonov@gmail.com"
    Then andrei.filimonov@gmail.com should receive an invitation mail 
    When he logs out
    And andrei.filimonov@gmail.com accepts an invitation
    Then andrei.filimonov@gmail.com, as a priority user, should see his info in user panel

  Scenario: Admin adds new lector
    Given an admin exists with a name of "Zahhar"
    When Zahhar logs in
    And he adds new lector with a name of "Andrei"
    Then lectors page should contain info about Andrei

#Then show me the page