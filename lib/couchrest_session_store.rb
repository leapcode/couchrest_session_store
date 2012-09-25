require 'couchrest'
require 'couchrest_model'

# CouchDB session storage for Rails.
#
# It will automatically pick up the config/couch.yml file for CouchRest Model
#
# Options:
# :database => database to use combined with config prefix and suffix
#
class CouchRestSessionStore < ActionDispatch::Session::AbstractStore

  include CouchRest::Model::Configuration
  include CouchRest::Model::Connection

  class << self
    def marshal(data)
      ::Base64.encode64(Marshal.dump(data)) if data
    end

    def unmarshal(data)
      Marshal.load(::Base64.decode64(data)) if data
    end

  end

  def initialize(app, options = {})
    super
    self.class.use_database options[:database] || "sessions"
  end

  # just fetch from the config
  def self.database
    @database ||= prepare_database
  end

  def database
    self.class.database
  end

  private

  def get_session(env, sid)
    debugger
    if sid
      doc = database.get(sid)
      session = self.class.unmarshal(doc["data"])
    else
      sid = generate_sid
      session = {}
      doc = CouchRest::Document.new "_id" => sid,
        "data" => self.class.marshal(session)
      database.save_doc(doc)
    end
    return [sid, session]
  end

  def set_session(env, sid, session, options)
    doc = database.get(sid)
    doc["data"] = self.class.marshal(session)
    database.save_doc(doc)
    return sid
  end
end

