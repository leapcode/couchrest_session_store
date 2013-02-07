require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class SessionStoreTest < MiniTest::Unit::TestCase

  def setup
    @app = nil
    @store = CouchRestSessionStore.new(@app)
    @env = {}
  end

  def test_normal_session_flow
    sid, session = @store.send :get_session, @env, nil
    assert sid
    assert_equal Hash.new, session
    session[:key] = "stub"
    @store.send :set_session, @env, sid, session, {}
    assert_equal [sid, session], @store.send(:get_session, @env, sid)
    @store.send :destroy_session, @env, sid, {}
  end

  def test_logout_in_between
    sid, session = @store.send :get_session, @env, nil
    session[:key] = "stub"
    @store.send :set_session, @env, sid, session, {}
    @store.send :destroy_session, @env, sid, {}
    other_sid, other_session = @store.send(:get_session, @env, sid)
    assert_equal Hash.new, other_session
  end

  def test_can_logout_twice
    sid, session = @store.send :get_session, @env, nil
    session[:key] = "stub"
    @store.send :set_session, @env, sid, session, {}
    @store.send :destroy_session, @env, sid, {}
    @store.send :destroy_session, @env, sid, {}
    other_sid, other_session = @store.send(:get_session, @env, sid)
    assert_equal Hash.new, other_session
  end

end
