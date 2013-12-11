#
# Access the couch directly so we can test its state without relying
# on the SessionStore
#

class CouchTester < CouchRest::Document
  include CouchRest::Model::Configuration
  include CouchRest::Model::Connection

  use_database 'sessions'

  def initialize(options = {})
    if options[:database]
      self.class.use_database options[:database]
    end
  end

  def get(sid)
    database.get(sid)
  end

  def update(sid, diff)
    doc = database.get(sid)
    doc.merge! diff
    database.save_doc(doc)
  end

end
