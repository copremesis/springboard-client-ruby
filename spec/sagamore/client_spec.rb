require 'spec_helper'

describe Sagamore::Client do
  include_context "client"

  describe "session" do
    it "should be a Patron::Session" do
      client.session.should be_a Patron::Session
    end
  end

  describe "auth" do
    it "should attempt to authenticate with the given username and password" do
      request_stub = stub_request(:post, "#{base_url}/auth/identity/callback").
        with(:body => "auth_key=coco&password=boggle")
      client.auth(:username => 'coco', :password => 'boggle')
      request_stub.should have_been_requested
    end
    
    it "should raise an exception if called without username or password" do
      lambda { client.auth }.should raise_error("Must specify :username and :password")
      lambda { client.auth(:username => 'x') }.should raise_error("Must specify :username and :password")
      lambda { client.auth(:password => 'y') }.should raise_error("Must specify :username and :password")
    end

    it "should return true if auth succeeds" do
      stub_request(:post, "#{base_url}/auth/identity/callback").to_return(:status => 200)
      lambda { client.auth(:username => 'someone', :password => 'right') }.should be_true
    end

    it "should raise an AuthFailed if auth fails" do
      stub_request(:post, "#{base_url}/auth/identity/callback").to_return(:status => 401)
      lambda { client.auth(:username => 'someone', :password => 'wrong') }.should \
        raise_error(Sagamore::Client::AuthFailed, "Sagamore auth failed")
    end
  end

  describe "initialize" do
    it "should call configure_session" do
      Sagamore::Client.any_instance.should_receive(:configure_session).with(base_url, {:x => 'y'})
      Sagamore::Client.new(base_url, :x => 'y')
    end
  end

  describe "configure_session" do
    it "should set the session's base_url" do
      session.should_receive(:base_url=).with(base_url)
      client.__send__(:configure_session, base_url, :x => 'y')
    end

    it "should enable cookies" do
      session.should_receive(:handle_cookies)
      client.__send__(:configure_session, base_url, :x => 'y')
    end

    it "should allow setting insecure on the session" do
      session.should_receive(:insecure=).with(true)
      client.__send__(:configure_session, base_url, :insecure => true)
    end
  end

  describe "get" do
    it "should call session's get" do
      session.should_receive(:get).with('/relative/path', {})
      client.get('/relative/path')
    end
  end

  describe "get!" do
    it "should raise an exception on failure" do
      stub_request(:get, base_url+'/').to_return(:status => 404)
      lambda { client.get!('/') }.should raise_error(Sagamore::Client::RequestFailed)
    end
  end

  describe "post" do
    it "should call session's post" do
      session.should_receive(:post).with('/relative/path', 'body', {})
      client.post('/relative/path', 'body')
    end

    it "should serialize the request body as JSON if it is a hash" do
      body_hash = {:key1 => 'val1', :key2 => 'val2'}
      session.should_receive(:post).with('/path', body_hash.to_json, {})
      client.post('/path', body_hash)
    end
  end
end
