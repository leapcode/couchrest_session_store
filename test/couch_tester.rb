class CouchTester
  include CouchRest::Model::Configuration
  include CouchRest::Model::Connection

  attr_reader :database

  def initialize(options = {})
    @database = self.class.use_database options[:database] || "sessions"
  end
end
