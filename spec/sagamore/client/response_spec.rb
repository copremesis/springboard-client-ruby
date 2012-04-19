require 'spec_helper'

describe Sagamore::Client::Response do
  include_context "client"

  let(:raw_body) { '{"key":"value"}' }
  let(:raw_headers) { 'X-Custom-Header: Hi' }
  let(:status_code) { 200 }
  let(:path) { '/path' }
  let(:patron_response) { Patron::Response.new(path, status_code, 0, raw_headers, raw_body) }
  let(:response) { Sagamore::Client::Response.new(patron_response, client) }

  describe "body" do
    it "should return a Sagamore::Client::Body" do
      response.body.should be_a Sagamore::Client::Body
    end

    it "should wrap the parsed response body" do
      response.body.to_hash.should == {"key" => "value"}
    end
  end

  describe "raw_body" do
    it "should return the raw body JSON" do
      response.raw_body.should == raw_body
    end
  end

  describe "headers" do
    it "should return the response headers as a hash" do
      response.headers.should == {'X-Custom-Header' => 'Hi'}
    end
  end

  describe "resource" do
    describe "when Location header is returned" do
      let(:raw_headers) { 'Location: /new/path' }

      it "should be a Sagamore::Client::Resource" do
        response.resource.should be_a Sagamore::Client::Resource
      end

      it "should have the Location header value as its URL" do
        response.resource.uri.to_s.should == '/new/path'
      end
    end

    describe "when Location header is not returned" do
      let(:raw_headers) { '' }

      it "should be nil" do
        response.resource.should be_nil
      end
    end
  end

  describe "[]" do
    it "should forward [] to body" do
      response.body.should_receive(:[]).with("key").and_return("value")
      response["key"].should == "value"
    end
  end

  describe "success?" do
    %w{100 101 102 200 201 202 203 204 205 206 207 208 226 300 301 302 303 304 305 306 307 308}.each do |code|
      it "should return true if the response status code is #{code}" do
        response.stub!(:status).and_return(code.to_i)
        response.success?.should === true
      end
    end

    %w{400 401 402 403 404 405 406 407 408 409 410 411 412 413 414 415 416 417 418 420 422 423 424 425 426 428 429 431
       444 449 450 499 500 501 502 503 504 505 506 507 508 509 510 511 598 599}.each do |code|
      it "should return false if the response status code is #{code}" do
        response.stub!(:status).and_return(code.to_i)
        response.success?.should === false
      end
    end
  end
end
