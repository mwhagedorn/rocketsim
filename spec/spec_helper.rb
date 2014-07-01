require 'simplecov'
require "multi_json"
SimpleCov.start do
  add_filter "/spec/"
end

require 'minitest/autorun'
require 'minitest/spec'
require "minitest/reporters"


MiniTest::Reporters.use!