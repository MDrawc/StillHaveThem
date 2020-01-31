source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

# Rails
gem 'rails', '~> 5.2.3'
# Bcrypt for users passwords
gem 'bcrypt', '~>3.1.7'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Ruby gem to load environment variables from `.env`.
gem 'dotenv-rails', groups: [:development, :test]
# jQuery
gem 'jquery-rails'
# UIKit 3 for Ruby on Rails
gem 'rails-uikit', git: 'git://github.com/nicbet/rails-uikit.git'
# Gem for charts
gem "chartkick", ">= 3.3.0"
#Office Open XML Spreadsheet generator for the Ruby programming language
gem 'caxlsx'
# Provides a .axlsx renderer to Rails so you can move all your spreadsheet code from your controller into view files.
gem 'axlsx_rails'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Will paginate
gem 'will_paginate', '~> 3.1', '>= 3.1.7'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Ransack
gem 'ransack', github: 'activerecord-hackery/ransack'
# Amoeba - easy cloning of active_record objects including associations
gem 'amoeba'
# Random color generator
gem 'color-generator', '~> 0.0.4'
# A library for bulk insertion of data into your database using ActiveRecord
gem 'activerecord-import'
# Remediation
# Upgrade nokogiri to version 1.10.4 or later. For example:
gem "nokogiri", ">= 1.10.4"

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Use Puma as the app server
 gem "puma", ">= 3.12.2"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
