# coding: utf-8
$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "social_framework/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "social_framework"
  s.version     = SocialFramework::VERSION
  s.authors     = ["Jefferson Xavier", "Álex Mesquita"]
  s.email       = ["jeffersonx.xavier@gmail.com", "alex.mesquita0608@gmail.com"]
  s.summary     = "Summary"
  s.description = "Framework to build social networks apps base on routes and schedules."
  s.license     = "MIT"
  s.homepage    = "https://github.com/TCC-SocialNetwork/social_framework"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", '~> 4.2'
  s.add_dependency "devise", '~> 3.5'
end
