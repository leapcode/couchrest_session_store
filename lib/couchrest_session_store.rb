require 'couchrest'
require 'couchrest_model'
require 'action_dispatch'

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
    if sid
      doc = database.get(sid)
      session = self.class.unmarshal(doc["data"])
      [sid, session]
    else
      [generate_sid, {}]
    end
  rescue RestClient::ResourceNotFound
    # session data does not exist anymore
    return [sid, {}]
  end

  def set_session(env, sid, session, options)
    doc = build_or_update_doc(sid, self.class.marshal(session))
    database.save_doc(doc)
    return sid
  end

  def destroy_session(env, sid, options)
    doc = database.get(sid)
    database.delete_doc(doc)
    options[:drop] ? nil : generate_sid
  rescue RestClient::ResourceNotFound
    # already destroyed - we're done.
  end


  def build_or_update_doc(sid, data)
    doc = database.get(sid)
    doc["data"] = data
    return doc
  rescue RestClient::ResourceNotFound
    return CouchRest::Document.new "_id" => sid, "data" => data
  end

end

