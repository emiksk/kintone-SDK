require 'faraday'
require 'faraday_middleware'
require 'base64'
require 'json'
require 'kintone_sdk/client/record'
require 'kintone_sdk/errors'

module KintoneSDK

  class Client
    BASE_PATH = '/k/v1'

    def initialize(domain, auth_params = {})
      @connection =  Faraday.new(url: "https://#{domain}", headers: auth_headers(auth_params)) do |builder|
        builder.request :url_encoded
        builder.request :multipart
        builder.response :json, contet_type: /\bjson$/
        builder.adapter :net_http
      end

      yield(@connection) if block_given?
    end

    def record
      @record ||= KintoneSDK::Client::Record.new(self)
    end

    def get(url, params = {})
      response = @connection.get do |request|
        request.url url
        request.headers['Content-Type'] = 'application/json'
        request.body = params.to_json
      end
      raise KintoneSDK::KintoneHTTPError.new(response.body, response.status) if response.status != 200
      response
    end

    def post(url, payload)
      response = @connection.post do |request|
        request.url url
        request.headers['Content-Type'] = 'application/json'
        request.body = payload.to_json
      end
      raise KintoneSDK::KintoneHTTPError.new(response.body, response.status) unless response.success?
      response
    end

    def put(url, payload)
      response = @connection.put do |request|
        request.url url
        request.headers['Content-Type'] = 'application/json'
        p payload
        request.body = payload.to_json
      end
      raise KintoneSDK::KintoneHTTPError.new(response.body, response.status) unless response.success?
      response
    end

    def delete(url, payload)
      response = @connection.delete do |request|
        request.url url
        request.headers['Content-Type'] = 'application/json'
        request.body = payload.to_json
      end
      raise KintoneSDK::KintoneHTTPError.new(response.body, response.status) unless response.success?
      response
    end

    private

    def auth_headers(params)
      if params[:user] && params[:password]
        { 'X-Cybozu-Authorization' => Base64.strict_encode64("#{params[:user]}:#{params[:password]}") }
      else
        { 'X-Cybozu-API-Token' => params[:token] }
      end
    end

  end #  class Client

end # module KintoneSdk
