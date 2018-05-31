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
        # KintoneSDK::Resource::Record.new(@client, response.body)
      end

      def update(app_id, payload, options = {})
        body = convert_for_kintone(app_id, payload, options)
        response = @client.put(@url, body)
        # KintoneSDK::Resource::Record.new(@client, response.body)
      end

      def delete(app_id, record_id)
        # Oh My kintone API !!!!!!!!!!
        url = @url.gsub(/record.json$/, "records.json")

        @client.delete(url, app: app_id, ids: [record_id])
      end

      private

      # This may be moved to Base class if other resourses are implemented
      def get_url
        KintoneSDK::Client::BASE_PATH + self.class.path
      end

      # to be continue...
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
