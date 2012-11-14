require 'rubygems'
require "bundler"
Bundler.setup(:default, :test)

require 'minitest/benchmark'
require 'minitest/autorun'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'upload_detector'
