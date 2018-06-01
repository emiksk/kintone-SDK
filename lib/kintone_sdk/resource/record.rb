require 'kintone_sdk/resource/field'
require 'kintone_sdk/resource/table'
require 'kintone_sdk/resource/row'

module KintoneSDK

  module Resource

    class Record
      READONLY_FIELDS =
          [
            :RECORD_NUMBER,
            :__ID__,
            :__REVISION__,
            :CREATOR,
            :CREATED_TIME,
            :MODIFIER,
            :UPDATED_TIME,
            :STATUS,
            :CATEGORY,
            :CALC,
            :STATUS_ASSIGNEE
          ].freeze

      def initialize(app_id, options = {})
        @app_id = app_id
        @client = options.delete(:client)
        @guest_space_id = options.delete(:guest_space_id)
        @options = options
        @fields = {}
      end
      attr_accessor :app_id, :guest_space_id

      def id
        self[:$id]
      end

      def [](key)
        @fields[key.to_s]&.value
      end

      def []=(key, val)
        raise KintoneSDK::ReadOnlyError.new(key, @fields[key.to_s]&.type) if READONLY_FIELDS.include?(@fields[key.to_s]&.type)
        @fields[key.to_s] = Field.create(val)
      end

      def get_field(key)
        @fields[key.to_s]
      end

      def set_field(key, value, type)
        @fields[key.to_s] = Field.create(value, type.to_sym)
      end

      def field_codes
        @fields.map { |k, v| v.type == :SUBTABLE ? [k, v.field_codes] : k }.flatten
      end

      def field_values
        @fields.values.map(&:value)
      end

      def register
        # if this record already exist in kintone, it can't be registered
        raise KintoneSDK::ExistedRecordError.new(@app_id, id) if id
        response = @client.post(@app_id, self, guest_space_id: @guest_space_id)
        sync(:register, response)
      end

      def update
        response = @client.update(@app_id, self, guest_space_id: @guest_space_id)
        sync(:update, response)
      end

      def delete
        response = @client.delete(@app_id, id, guest_space_id: @guest_space_id)
        sync(:delete, response)
      end

      def request_body_format(for_update = nil)
        {}.tap do |hash|
          hash.merge!(app: @app_id, record: {})
          hash.merge!(id: id) if for_update
          @fields.each do |key, field|
            next if READONLY_FIELDS.include?(field.type)
            hash[:record][key] = field.request_body_format(for_update)
          end
        end
      end

      private

      def sync(method, response)
        body = response.body
        case(method)
        when :register
          set_field(:$id, body["id"], "__ID__")
          set_field(:$revision, body["revision"], "__REVISION__")
        when :update
          set_field(:$revision, body["revision"], "__REVISION__")
        when :delete
          set_field(:$id, nil, "__ID__")
        end

        self
      end

    end # class Record

  end # module Resource

end # module KintoneSDK
