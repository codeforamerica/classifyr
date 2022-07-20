source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

gem "rails", "~> 7.0", ">= 7.0.2.3"
gem "sprockets-rails", "~> 3.4"
gem "pg", "~> 1.3"
gem "puma", "~> 5.6"
gem "importmap-rails", "~> 1.1"
gem "turbo-rails", "~> 1.1"
gem "stimulus-rails", "~> 1.0"
gem "tailwindcss-rails", "~> 2.0"
gem "jbuilder", "~> 2.11"
gem "seed_dump", "~> 3.3"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "bootsnap", "~> 1.11", require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", "~> 1.5", platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console", "~> 4.2"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem "rubocop-rails", "~> 2.15", require: false
  gem "rubocop-performance", "~> 1.14", require: false
  gem "rubocop-rspec", "~> 2.12", require: false
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara", "~> 3.37"
  gem "selenium-webdriver", "~> 4.1"
  gem "webdrivers", "~> 5.0"
end
