require 'couchrest/session/utility'

class CouchRest::Session::Document
  include CouchRest::Session::Utility

  def initialize(doc=nil)
    @doc = doc
  end

  def self.load(sid)
    self.new.tap do |session_doc|
      session_doc.load(sid)
    end
  end

  def self.build(sid, session, marshal_data)
    self.new(CouchRest::Document.new({"_id" => sid})).tap do |session_doc|
      session_doc.update session, marshal_data
    end
  end

  def load(sid)
    @doc = database.get(sid)
  end

  def to_session
    if doc["not_marshalled"]
      session = doc.to_hash
      session.delete("not_marshalled")
    else
      session = unmarshal(doc["data"])
    end
    return session
  end

  def delete
    database.delete_doc(doc)
  end

  def update(session, marshal_data)
    # clean up old data but leave id and revision intact
    doc.reject! do |k,v|
      k[0] != '_'
    end
    doc.merge! data_for_doc(session, marshal_data)
  end

  def save
    database.save_doc(doc)
  end

  protected

  def data_for_doc(session, marshal_data)
    if marshal_data
      { "data" => marshal(session) }
    else
      session.merge({"not_marshalled" => true})
    end
  end

  def doc
    @doc
  end

end
