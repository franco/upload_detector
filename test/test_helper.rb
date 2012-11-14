require 'rubygems'
require "bundler"
Bundler.setup(:default, :test)

require 'minitest/benchmark'
require 'minitest/autorun'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'upload_detector'

module Fixture
  def self.fixture_path
    File.join(File.dirname(__FILE__), 'fixtures')
  end
  def self.load name
    File.open(File.join(fixture_path, name))
  end
end
