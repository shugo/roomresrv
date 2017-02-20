require "simplecov"
SimpleCov.start("rails")
if ENV["UPLOAD_TO_CODECOV"]
  require "codecov"
  module IgnoreFormatError
    def format(*args)
      super(*args)
    rescue => e
      { 
        "error" => {
          "message" => e.message,
          "class" => e.class.name,
          "backtrace" => e.backtrace
        }
      }
    end
  end
  SimpleCov::Formatter::Codecov.send(:prepend, IgnoreFormatError)
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionController::TestCase
  def json
    @json ||= JSON.parse(response.body)
  end
end
