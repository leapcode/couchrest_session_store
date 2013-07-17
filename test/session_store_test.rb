require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class SessionStoreTest < MiniTest::Test

  def setup
    @app = nil
    @store = CouchRestSessionStore.new(@app)
    @env = {}
    @sid, @session = @store.send :get_session, @env, nil
    @session[:key] = "stub"
  end

  def test_session_initialization
    sid, session = @store.send :get_session, @env, nil
    assert sid
    assert_equal Hash.new, session
  end

  def test_normal_session_flow
    @store.send :set_session, @env, @sid, @session, {}
    assert_equal [@sid, @session], @store.send(:get_session, @env, @sid)
    @store.send :destroy_session, @env, @sid, {}
  end

  def test_updating_session
    @store.send :set_session, @env, @sid, @session, {}
    @session[:bla] = "blub"
    @store.send :set_session, @env, @sid, @session, {}
    assert_equal [@sid, @session], @store.send(:get_session, @env, @sid)
    @store.send :destroy_session, @env, @sid, {}
  end

  def test_unmarshalled_session_flow
    @store.send :set_session, @env, @sid, @session, {:marshal_data => false}
    new_sid, new_session = @store.send(:get_session, @env, @sid)
    assert_equal @sid, new_sid
    assert_equal @session[:key], new_session["key"]
    @store.send :destroy_session, @env, @sid, {}
  end

  def test_unmarshalled_data
    @store.send :set_session, @env, @sid, @session, {:marshal_data => false}
    database = CouchTester.new.database
    data = database.get(@sid)
    assert_equal @session[:key], data["key"]
  end

  def test_logout_in_between
    @store.send :set_session, @env, @sid, @session, {}
    @store.send :destroy_session, @env, @sid, {}
    other_sid, other_session = @store.send(:get_session, @env, @sid)
    assert_equal Hash.new, other_session
  end

  def test_can_logout_twice
    @store.send :set_session, @env, @sid, @session, {}
    @store.send :destroy_session, @env, @sid, {}
    @store.send :destroy_session, @env, @sid, {}
    other_sid, other_session = @store.send(:get_session, @env, @sid)
    assert_equal Hash.new, other_session
  end

end
