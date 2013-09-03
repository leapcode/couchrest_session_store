require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class SessionStoreTest < MiniTest::Test

  def test_session_initialization
    sid, session = store.send :get_session, env, nil
    assert sid
    assert_equal Hash.new, session
  end

  def test_normal_session_flow
    sid, session = init_session
    store_session(sid, session)
    assert_equal [sid, session], store.send(:get_session, env, sid)
    store.send :destroy_session, env, sid, {}
  end

  def test_updating_session
    sid, session = init_session
    store_session(sid, session)
    session[:bla] = "blub"
    store.send :set_session, env, sid, session, {}
    assert_equal [sid, session], store.send(:get_session, env, sid)
    store.send :destroy_session, env, sid, {}
  end

  def test_unmarshalled_session_flow
    sid, session = init_session
    store.send :set_session, env, sid, session, {:marshal_data => false}
    new_sid, new_session = store.send(:get_session, env, sid)
    assert_equal sid, new_sid
    assert_equal session[:key], new_session["key"]
    store.send :destroy_session, env, sid, {}
  end

  def test_unmarshalled_data
    sid, session = init_session
    store.send :set_session, env, sid, session, {:marshal_data => false}
    database = CouchTester.new.database
    data = database.get(sid)
    assert_equal session[:key], data["key"]
  end

  def test_logout_in_between
    sid, session = init_session
    store_session(sid, session)
    store.send :destroy_session, env, sid, {}
    other_sid, other_session = store.send(:get_session, env, sid)
    assert_equal Hash.new, other_session
  end

  def test_can_logout_twice
    sid, session = init_session
    store_session(sid, session)
    store.send :destroy_session, env, sid, {}
    store.send :destroy_session, env, sid, {}
    other_sid, other_session = store.send(:get_session, env, sid)
    assert_equal Hash.new, other_session
  end

  def test_stored_and_not_expired_yet
    store(expire_after: 30)
    sid, session = init_session
    store_session(sid, session)
    assert_equal [sid, session], store.send(:get_session, env, sid)
  end

  def test_stored_but_expired
    clock = TestClock.new
    store(expire_after: 30, clock: clock)
    sid, session = init_session
    store_session(sid, session)
    clock.tick
    other_sid, other_session = store.send(:get_session, env, sid)
    assert_equal Hash.new, other_session, "session should have expired"
    assert other_sid != sid
  end

  def test_store_without_expiry
    clock = TestClock.new(100000)
    store(clock: clock)
    sid, session = init_session
    store_session(sid, session)
    clock.tick
    assert_equal [sid, session], store.send(:get_session, env, sid)
  end

  def app
    nil
  end

  def store(options = {})
    @store ||= CouchRest::SessionStore.new(app, options)
  end

  def env(settings = {})
    env ||= settings
  end

  def init_session
    sid, session = store.send :get_session, env, nil
    session[:key] = "stub"
    return sid, session
  end

  def store_session(sid, session)
    store.send :set_session, env, sid, session, {}
  end
end
