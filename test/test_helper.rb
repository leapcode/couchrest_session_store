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
db = CouchRest::Session::Document.database!
begin
  db.get('_design/Session')
rescue RestClient::ResourceNotFound
  design = File.read(File.expand_path('../../design/Session.json', __FILE__))
  design = JSON.parse(design)
  db.save_doc(design.merge({"_id" => "_design/Session"}))
end
