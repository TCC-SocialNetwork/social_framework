source 'https://rubygems.org'

# Declare your gem's dependencies in social_framework.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]

group :development, :test do
  gem 'rspec-rails', '~> 3.0'
end

group :development do
  gem 'byebug'
end

group :test do
  gem "codeclimate-test-reporter", require: nil
  gem "factory_girl"
  gem "generator_spec"
end

gem 'sqlite3'
gem 'devise', '~> 3.5.6'
gem 'mysql2'
gem 'simplecov', :require => false, :group => :test
