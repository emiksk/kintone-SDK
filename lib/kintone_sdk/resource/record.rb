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

      class Field
        def self.create(value, type = nil)
          if value.is_a?(Array) && (type == nil || type == :SUBTABLE)
            Table.new(value, type)
          else
            Field.new(value, type)
          end
        end

        def initialize(val, type = :UNKNOWN)
          @value = val
          @type = type
        end
        attr_accessor :value, :type

        def request_body_format(for_update = nil)
          {value: @value}
        end

      end # class Field

      class Table
        include Enumerable

        def initialize(rows, type = nil)
          @type = type || :SUBTABLE
          @rows = parse_rows(rows)
        end
        attr_reader :type

        def value
          @rows.map(&:value)
        end

        def field_codes
          @rows.first.field_codes
        end

        def each
          @rows.each do |row|
            yield row
          end
        end

        def [](idx)
          @rows[idx]
        end

        def []=(idx, val)
          @rows[idx] = Row.new(val)
        end

        def get_row_by_id(id)
          @rows.find { |el| el.id == id  }
        end

        def set_row_by_id(id, val)
          row = get_row_by_id(id)
          row = val
        end

        def request_body_format(for_update)
          {value: @rows.map { |row| row.request_body_format(for_update) } }
        end

        private

        def parse_rows(rows)
          rows.map do |row|
            Row.new(row)
          end
        end

      end # class Table

      class Row
        include Enumerable

        def initialize(row)
          @id =row["id"]
          @fields = parse_fields(row["value"])
        end
        attr_reader :id

        def value
          @fields.map { |k, v| v.value }
        end

        def field_codes
          @fields.keys
        end

        def each
          @fields.each do |key, value|
            yield key, value
          end
        end

        def [](key)
          @fields[key.to_s]
        end

        def []=(key, val)
          # raise KintoneSDK::TableInTableError.new id val.is_a?(Array)
          @fields[key.to_s] = Field.new(val)
        end

        def request_body_format(for_update)
          {}.tap do |hash|
            hash[:id] = @id if for_update
            hash[:value] = {}.tap do |h|
              @fields.each do |key, field|
                h[key] = field.request_body_format
              end
            end
          end
        end

        private

        def parse_fields(fields)
          {}.tap do |hash|
            fields.each do |key, field|
              hash[key.to_s] = Field.new(field["value"], field["type"]&.to_sym)
            end
          end
        end

      end # class Row

    end # class Record

  end # module Resource

end # module KintoneSDK
