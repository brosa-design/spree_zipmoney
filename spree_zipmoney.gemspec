# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_zipmoney'
  s.version     = '3.1.0'
  s.summary     = 'Zipmoney Integration for SpreeCommerce'
  s.description = 'Zipmoney Integration for SpreeCommerce'
  s.required_ruby_version = '>= 2.1.0'

  s.author    = 'Jatin Baweja'
  s.email     = 'info@vinsol.com'
  s.homepage  = 'http://www.vinsol.com'
  s.license = 'BSD-3'

  # s.files       = `git ls-files`.split("\n")
  # s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 3.1.2'
  s.add_dependency 'zipMoney', '~> 1.0.7'
  s.add_dependency 'httparty', '~> 0.14.0'

  s.add_development_dependency 'byebug'
  s.add_development_dependency 'capybara', '~> 2.6'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.5'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails', '~> 3.4'
  s.add_development_dependency 'sass-rails', '~> 5.0.0'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'shoulda-matchers', '~> 3.1.0'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-activemodel-mocks'
end
