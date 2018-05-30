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
        body = convert_for_kintone(app_id, payload)
        response = @client.put(@url, fmt)
        # KintoneSDK::Resource::Record.new(@client, response.body)
      end

      def delete(app_id, record_id)
        # oh my kintone API !!!!!!!!!!
        url = @url.gsub(/record.json$/, "records.json")
        p url
        @client.delete(url, app: app_id, ids: [record_id])
      end

      private

      # This may be moved to Base class if other resourses are implemented
      def get_url
        KintoneSDK::Client::BASE_PATH + self.class.path
      end

      # to be continue...
      def convert_for_kintone(app_id, hash)
        body = { app: app_id }
        if hash[:id]

        else

        end
      end

    end # class Record

  end #  class Client

end # module KintoneSDK
