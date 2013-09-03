class CouchRest::Session::Document

  def initialize(doc)
    @doc = doc
  end

  def self.load(sid)
    self.new(database.get(sid))
  end

  def self.build(data)
    self.new(CouchRest::Document.new(data))
  end

  def self.database
    CouchRest::Session::Store.database
  end

  def to_session
    if doc["not_marshalled"]
      session = doc.to_hash
      session.delete("not_marshalled")
    else
      session = CouchRest::Session::Store.unmarshal(doc["data"])
    end
    return session
  end

  def delete
    database.delete_doc(doc)
  end

  def update(data)
    # clean up old data but leave id and revision intact
    doc.reject! do |k,v|
      k[0] != '_'
    end
    doc.merge! data
  end

  def save
    database.save_doc(doc)
  end

  protected

  def doc
    @doc
  end

  def database
    CouchRest::Session::Store.database
  end
end
