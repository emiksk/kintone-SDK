require 'kintone_sdk/resource'

module KintoneSDK

  class Client

    class Record

      def self.path
        '/record.json'
      end

      def initialize(client)
        @client = client
        @url = get_url
      end

      def get(app_id, record_id)
        response = @client.get(@url, app: app_id, id: record_id)
        create_record_from_response(app_id, response.body)
      end

      def post(app_id, record, options = {})
        if record.is_a?(KintoneSDK::Resource::Record)
          payload = record.request_body_format
        end

        @client.post(@url, payload)
      end

      def update(app_id, record, options = {})
        if record.is_a?(KintoneSDK::Resource::Record)
          payload = record.request_body_format(for_update = true)
        else
          payload = convert_for_kintone(app_id, payload, options)
        end

        response = @client.put(@url, payload)
        # FIXME: Must change revision in Record object
      end

      def delete(app_id, record_id)
        # Oh My kintone API !!!!!!!!!!
        url = @url.gsub(/record.json$/, "records.json")

        @client.delete(url, app: app_id, ids: [record_id])
      end

      def new(app_id, options = {})
        record = KintoneSDK::Resource::Record.new(app_id, options.merge(client: self))

        yield(record) if block_given?

        record
      end

      private

      # This may be moved to Base class if other resourses are implemented
      def get_url
        KintoneSDK::Client::BASE_PATH + self.class.path
      end

      def create_record_from_response(app_id, body)
        self.new(app_id) do |record|
          body["record"].each do |key, field|
            record.set_field(key, field["value"], field["type"])
          end
        end
      end

      # ugly implemention !
      def convert_for_kintone(app_id, hash, options = {})
        body = { app: app_id, record: {} }

        # for id
        body[:id] = options[:id] if options[:id]

        # for  updatekey
        body[:updateKey] = options[:update_key] if !body[:id] && options[:update_key]

        # for revision
        body[:revision] = options{:revision} if options[:revision]

        # for fields
        hash.each do |field_code, value|
          body[:record][field_code] =
            if value.is_a?(Array)
              # if  field type is table, value contains id, field_codes and value in table
              {}.tap do |table_value|
                table_value[:value] = value.map do |el|
                  {}.tap do |hash|
                    hash[:id] = el[:id]
                    hash[:value] = {}
                    el[:value].each do |tf_code, val|
                      hash[:value][tf_code] = {value: val}
                    end
                  end
                end
              end
            else
              {value: value}
            end
        end

        body
      end

    end # class Record

  end #  class Client

end # module KintoneSDK
