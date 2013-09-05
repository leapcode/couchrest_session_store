require 'couchrest/session/utility'

class CouchRest::Session::Document
  include CouchRest::Session::Utility

  def initialize(doc)
    @doc = doc
  end

  def self.load(sid)
    self.allocate.tap do |session_doc|
      session_doc.load(sid)
    end
  end

  def self.build(sid, session, options)
    self.new(CouchRest::Document.new({"_id" => sid})).tap do |session_doc|
      session_doc.update session, options
    end
  end

  def load(sid)
    @doc = database.get(sid)
  end

  def to_session
    if doc["marshalled"]
      session = unmarshal(doc["data"])
    else
      session = doc["data"]
    end
    return session
  end

  def delete
    database.delete_doc(doc)
  end

  def update(session, options)
    # clean up old data but leave id and revision intact
    doc.reject! do |k,v|
      k[0] != '_'
    end
    doc.merge! data_for_doc(session, options)
  end

  def save
    database.save_doc(doc)
  end

  protected

  def data_for_doc(session, options)
    { "data" => options[:marshal_data] ? marshal(session) : session,
      "marshalled" => options[:marshal_data],
      "expires" => expires(options) }
  end

  def expires(options)
    nil
  end

  def doc
    @doc
  end

end
