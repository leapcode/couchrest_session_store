class CouchRest::Session::Store < ActionDispatch::Session::AbstractStore

  include CouchRest::Model::Configuration
  include CouchRest::Model::Connection

  def initialize(app, options = {})
    super
    self.class.set_options(options)
  end

  def self.set_options(options)
    @options = options
  end

  # just fetch from the config
  def self.database
    @database ||= initialize_database
  end

  def self.initialize_database
    use_database @options[:database] || "sessions"
  end

  private

  def get_session(env, sid)
    if sid
      doc = secure_get(sid)
      [sid, doc.to_session]
    else
      [generate_sid, {}]
    end
  rescue RestClient::ResourceNotFound
    # session data does not exist anymore
    return [sid, {}]
  end

  def set_session(env, sid, session, options)
    doc = build_or_update_doc(sid, session, options)
    doc.save
    return sid
  end

  def destroy_session(env, sid, options)
    doc = secure_get(sid)
    doc.delete
    generate_sid unless options[:drop]
  rescue RestClient::ResourceNotFound
    # already destroyed - we're done.
    generate_sid unless options[:drop]
  end

  def build_or_update_doc(sid, session, options)
    options[:marshal_data] = true if options[:marshal_data].nil?
    doc = secure_get(sid)
    doc.update(session, options)
    return doc
  rescue RestClient::ResourceNotFound
    CouchRest::Session::Document.build(sid, session, options)
  end

  # prevent access to design docs
  # this should be prevented on a couch permission level as well.
  # but better be save than sorry.
  def secure_get(sid)
    raise RestClient::ResourceNotFound if /^_design\/(.*)/ =~ sid
    CouchRest::Session::Document.load(sid)
  end
end

