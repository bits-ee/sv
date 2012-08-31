source 'http://rubygems.org'

gem 'rails', '3.2.2'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'mysql2'
gem 'haml'
gem 'paperclip', '2.4.5'#:git => 'git://github.com/thoughtbot/paperclip.git'
gem 'russian'
gem 'acts_as_commentable_with_threading', :git => 'git://github.com/dfischer/acts_as_commentable_with_threading.git'
gem 'http_accept_language'#, :git => 'git://github.com/iain/http_accept_language.git'
gem 'rinku' #auto_link method
gem 'shortly' #url shortener

gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'omniauth-vkontakte'
gem 'rack'#, '1.3.3'

gem 'spreadsheet'

group :development do
  #didn't work without these gems on Ubuntu 11.10
  gem 'execjs'
  gem 'therubyracer'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password method
gem 'bcrypt-ruby'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :development, :test do
  gem "rspec-rails"
end

group :test do
  gem "cucumber-rails"
  #gem "capybara-webkit"
  gem "capybara"
  gem "factory_girl_rails"
  gem "database_cleaner"
  gem "launchy"
  #gem "bourne"
  #gem "timecop"
  #gem "shoulda-matchers"
  #gem "email_spec"
end

#group :staging, :production do
#  gem 'newrelic_rpm'
#  gem 'sprockets-redirect'
#end
