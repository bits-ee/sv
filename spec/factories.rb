#Factory girl guide:
# https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md


#Here comes some constants for factory girl factories
PASSWORD_STUB = "stubpass".freeze

FactoryGirl.define do

  sequence :count do |n| n end;

  factory :contest do
    name "Contest #{FactoryGirl.generate(:count)}"
    name_en {name}
    name_es {name}
    deadline(Date.today+14)
  end

  factory :project do
    name {"Project#{FactoryGirl.generate(:count)}"}
    status Project.status_draft

    factory :ready_to_publish_project do
      synopsys 'project synopsis'
      details 'some details about project'
      team  'a couple of words about dreamteam'
      business_model 'easy way to earn money'
      market 'who is a typical client'
      competitors 'there are no competitors'
      advantages 'a huge list of advantages'
      technology 'ruby on rails, of course'
      finance '1 billion dollars from Bill Gates'
      current_stage 'just an idea'
    end
  end

  sequence :name do |n|
    names = %w[ Joe Bob Sue ]
    "#{names[rand 3]}#{n}"
  end

  factory :user do
    name FactoryGirl.generate(:name)
    email {"#{name}@example.com"}
    status User.status_active
    locale :en

    factory :regular_user do
      project
      user_type User.type_regular
      password PASSWORD_STUB
      password_confirmation PASSWORD_STUB

    end

    factory :priority_user do
      user_type User.type_priority
      password PASSWORD_STUB
      password_confirmation PASSWORD_STUB

      factory :invited_priority_user do
        name nil
        email {"#{name}@example.com"}
        status User.status_invited
        password nil
        password_confirmation nil
      end

      factory :admin do
        is_admin true
      end
    end

  end

end


# Factories
# Factory.define :article do |t|
# 	t.association :section # An article belongs to a section
# 	t.title {|x| "#{x.section.name}Article#{Factory.next(:count)}" }  # Use brackets when you're calling a sequence
# 	t.author "Author Bob"
#     # Assuming you have put "require 'forgery' " in the correct place.  It could just be in your seeds.rb file.
# 	t.body Forgery::LoremIpsum.paragraphs(5)
# 	t.status "status here"
# 	t.comments_allowed false
# 	t.notes "notes here"
# 	t.teaser "I am a teaser."
# 	t.styles "styles here"
# end

# Factory.define :comment do |t|
# 	t.association :article # A comment belongs to an article
# 	t.body Forgery::LoremIpsum.sentence
# 	t.full_name "Commenter Bob"
# 	t.email { Factory.next(:email) }
# end

# Factory.define :page do |t|
# 	t.title { "Page#{Factory.next(:count)}" } # Again, remember to have the brackets here when you're calling a sequence.
# 	t.styles "styles here"
# 	t.body Forgery::LoremIpsum.paragraphs(5)
# end

