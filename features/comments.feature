@focus
Feature: Comments
  In order to maintain comments
  As an admin
  I want a list of all comments and a delete-button for each comment
  
#  ROLES = [:guest, :confirmed_user, :author, :moderator, :maintainer, :admin]
#             0         1               2        3            4           5
  
  Background:
    Given the following user records
      | email            | name      | roles_mask | password         | password_confirmation | confirmed_at         |
      | admin@iboard.cc  | admin     | 5          | thisisnotsecret  | thisisnotsecret       | 2010-01-01 00:00:00  |
      | user@iboard.cc   | testmax   | 1          | thisisnotsecret  | thisisnotsecret       | 2010-01-01 00:00:00  |
      | guest@iboard.cc  | guest     | 0          | thisisnotsecret  | thisisnotsecret       | 2010-01-01 00:00:00  |
      | staff@iboard.cc  | staff     | 4          | thisisnotsecret  | thisisnotsecret       | 2010-01-01 00:00:00  |
    And the following page records
      | title  | body                 | show_in_menu | allow_public_comments | allow_comments |
      | Page 1 | Lorem ipsum          | true         | true                  | ture           |
      | Page 2 | Lirum Opsim          | false        | true                  | true           |
    And the following comment records for page "Page 1"
      | name | email    | comment          |
      | Andi | aa@bb.cc | My first Comment |
    And I am logged in as user "admin@iboard.cc" with password "thisisnotsecret"
 
  Scenario: Admin should see the Comments-menu item
    Given I am on the home page
    Then I should see "Comments" within ".hmenu"
    
  Scenario: Admin should see the list of comments
    Given I am on the comments page
    Then I should see "My first Comment"
    
  # TODO: This is no JS behavior! with JS the user will stay on the comments page!
  Scenario: Admin should be able to delete any comment
    Given I am on the comments page
    And I click on link "Delete"
    Then I should be on the page path of "Page 1"
    And I should not see "My first Comment"

  Scenario: Only moderators should see a the comments-menu-item
    Given I am logged out
    And I am on the home page
    Then I should not see "Comments" within ".hmenu"

  Scenario: Only moderators should see a list of all comments
    Given I am logged out
    And I am on the comments page
    Then I should be on the home page
    And I should see "not authorized"
    
  Scenario: Comments page should list ip-addresses of posters
    Given I am on the page path of "Page 1"
    And I fill in "Name" with "A Poster"
    And I fill in "Email" with "my@email.cc"
    And I fill in "Comment" with "A stupid comment but you got my IP"
    And I click on "Post comment"
    And I click on link "Comments" within ".hmenu"
    Then I should see "A stupid comment"
    And I should see "Posted from 127.0.0.1"
    
  Scenario: No comments if page.allow_comments is false
    Given the following page records
      | title         | body                 | allow_public_comments | allow_comments |
      | Uncommentable | Lorum Upsim          | false                 | false          |
    And I am on the page path of "Uncommentable"
    Then I should not see "Post a comment"

  Scenario: Allow comments if page.allow_comments is true
    Given the following page records
      | title         | body                 | allow_public_comments | allow_comments |
      | Commentable   | Lorum Upsim          | true                  | true           |
    And I am on the page path of "Commentable"
    Then I should see "Post a comment"

  Scenario: Allow comments if blog.allow_comments is true
    Given the following blog records
      | title       |  allow_public_comments | allow_comments |
      | Commentable |  true                  | true           |
    And the following posting records for blog "Commentable" and user "admin"
      | title       | body        |
      | Posting one | lorem ipsum |
    And I am on the blog path of "Commentable"
    And I click on link "Posting one"
    And I fill in "Comment" with "And here my comment"
    And I click on "Post comment"
    Then I should be on the read posting "Posting one" page of blog "Commentable"
    And I should see "Comment successfully created. You can edit it for the next"
    And I should see "And here my comment"

  Scenario: No comments should be allowed if blog.allow_comments is false
    Given the following blog records
      | title         |  allow_public_comments | allow_comments |
      | Uncommentable |  false                 | fale           |
    And the following posting records for blog "Uncommentable" and user "admin"
      | title       | body        |
      | Posting one | lorem ipsum |
    And I am on the blog path of "Uncommentable"
    And I click on link "Posting one"
    Then I should not see "Post a comment"

  


