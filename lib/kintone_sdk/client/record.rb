require 'kintone_sdk/resource'

module KintoneSDK

  class Client

    class Record
      METHOD_PATH =
        {
          get: "/record.json",
          post: "/record.json",
          put: "/record.json",
          delete: "/records.json"
        }.freeze

      def initialize(client)
        @client = client
      end

      def get(app_id, record_id, options = {})
        url = get_url(:get, options[:guest_space_id])
        response = @client.get(url, app: app_id, id: record_id)
        create_record_from_response(app_id, response.body)
      end

      def post(app_id, record, options = {})
        if record.is_a?(KintoneSDK::Resource::Record)
          payload = record.request_body_format
        end

        url = get_url(:post, options[:guest_space_id])
        @client.post(url, payload)
      end

      def update(app_id, record, options = {})
        if record.is_a?(KintoneSDK::Resource::Record)
          payload = record.request_body_format(for_update = true)
        else
          payload = convert_for_kintone(app_id, record, options)
        end

        url = get_url(:put, options[:guest_space_id])
        response = @client.put(url, payload)
        # FIXME: Must change revision in Record object
      end

      def delete(app_id, record_id, options = {})
        url = get_url(:delete, options[:guest_space_id])
        @client.delete(url, app: app_id, ids: [record_id])
      end

      def new(app_id, options = {})
        record = KintoneSDK::Resource::Record.new(app_id, options.merge(client: self))

        yield(record) if block_given?

        record
      end

      private

      def get_url(method, guest_space_id = nil)
        if guest_space_id
          base_path = KintoneSDK::Client::PRODUCT_CODE +
                      "/guest" +
                      "/" + guest_space_id.to_s +
                      KintoneSDK::Client::API_VERSION
        else
          base_path = KintoneSDK::Client::PRODUCT_CODE +
                      KintoneSDK::Client::API_VERSION
        end

        base_path + METHOD_PATH[method]
      end

      def create_record_from_response(app_id, body)
        self.new(app_id) do |record|
          body["record"].each do |key, field|
            record.set_field(key, field["value"], field["type"])
          end
        end
      end

      def convert_for_kintone(app_id, hash, options = {})
        body = { app: app_id, record: {} }

        # for id
        body[:id] = options[:id] if options[:id]

        # for  updatekey
        body[:updateKey] = options[:update_key] if !body[:id] && options[:update_key]

        # for revision
        body[:revision] = options{:revision} if options[:revision]

        # for fields
        body[:record] = fields_request(hash)

        body
      end

      def fields_request(fields)
        fields.merge(fields) do |code, value|
          if value.is_a?(Array)
            rows = value.map do |row|
              { id: row[:id], value: fields_request(row[:value]) }
            end
            { value: rows }
          else
            {value: value}
          end
        end
      end

    end # class Record

  end #  class Client

end # module KintoneSDK
