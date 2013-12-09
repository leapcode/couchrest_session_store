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

  def cleanup(rows)
    rows.each do |row|
      doc = CouchRest::Session::Document.load(row['id'])
      doc.delete
    end
  end

  def expired
    find_by_expires startkey: 1,
      endkey: Time.now.utc.iso8601
  end

  def never_expiring
    find_by_expires endkey: 1
  end

  def find_by_expires(options = {})
    options[:reduce] ||= false
    design = self.class.database.get '_design/Session'
    response = design.view :by_expires, options
    response['rows']
  end

  private

  def get_session(env, sid)
    if session = fetch_session(sid)
      [sid, session]
    else
      [generate_sid, {}]
    end
  rescue RestClient::ResourceNotFound
    # session data does not exist anymore
    return [sid, {}]
  end

  def set_session(env, sid, session, options)
    raise RestClient::ResourceNotFound if /^_design\/(.*)/ =~ sid
    doc = build_or_update_doc(sid, session, options)
    doc.save
    return sid
  rescue CouchRest::Model::Errors::ConnectionFailed
    return false
  end

  def destroy_session(env, sid, options)
    doc = secure_get(sid)
    doc.delete
    generate_sid unless options[:drop]
  rescue RestClient::ResourceNotFound
    # already destroyed - we're done.
    generate_sid unless options[:drop]
  end

  def fetch_session(sid)
    return nil unless sid
    doc = secure_get(sid)
    doc.to_session unless doc.expired?
  end

  def build_or_update_doc(sid, session, options)
    CouchRest::Session::Document.build_or_update(sid, session, options)
  end

  # prevent access to design docs
  # this should be prevented on a couch permission level as well.
  # but better be save than sorry.
  def secure_get(sid)
    raise RestClient::ResourceNotFound if /^_design\/(.*)/ =~ sid
    CouchRest::Session::Document.load(sid)
  end

end
