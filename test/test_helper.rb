require "rubygems"
gem 'minitest'
require 'minitest/autorun'
require File.expand_path(File.dirname(__FILE__) + '/../lib/couchrest_session_store.rb')
require File.expand_path(File.dirname(__FILE__) + '/couch_tester.rb')
require File.expand_path(File.dirname(__FILE__) + '/test_clock.rb')

#require 'debugger'

#
# Seed the design document if they don't already exist.
#
CouchRest::Session::Document.create_database!
