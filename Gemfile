source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

gem "rails", "~> 7.0", ">= 7.0.2.3"
gem "health-monitor-rails", "~> 9.3"
gem "sprockets-rails", "~> 3.4"
gem "pg", "~> 1.4"
gem "puma", "~> 5.6"
gem "importmap-rails", "~> 1.1"
gem "turbo-rails", "~> 1.1"
gem "stimulus-rails", "~> 1.1"
gem "tailwindcss-rails", "2.0.5"
gem "jbuilder", "~> 2.11"
gem "seed_dump", "~> 3.3"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "bootsnap", "~> 1.12", require: false
gem "paper_trail", "~> 12.3"
gem "devise", github: "heartcombo/devise", ref: "f8d1ea90bc3"
gem "active_storage_validations", "~> 0.9"
gem "kaminari", "~> 1.2"
gem "aws-sdk-rails", "~> 3.6"
gem "aws-sdk-s3", "~> 1.114"
gem "pg_search", "~> 2.3"
gem "chronic", "~> 0.10.2"
gem "csv", "~> 3.2.0"
gem "friendly_id", "~> 5.4.0"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", "~> 1.6", platforms: %i[mri mingw x64_mingw]
  gem "rspec-rails", "~> 5.1"
  gem "factory_bot_rails", "~> 6.2"
  gem "faker", "~> 2.21"
  gem "pry", "~> 0.14"
  gem "bullet", "~> 7.0"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console", "~> 4.2"
  gem "letter_opener", "~> 1.8"
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem "rubocop", "~> 1.32"
  gem "rubocop-rails", "~> 2.15"
  gem "rubocop-performance", "~> 1.14"
  gem "rubocop-rspec", "~> 2.12"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara", "~> 3.37"
  gem "capybara-screenshot", "~> 1.0"
  gem "selenium-webdriver", "~> 4.3"
  gem "webdrivers", "~> 5.0"
  gem "webmock", "~> 3.14"
  gem "vcr", "~> 6.1"
  gem "database_cleaner-active_record", "~> 2.0"
  gem "nokogiri", "~> 1.13"
end
