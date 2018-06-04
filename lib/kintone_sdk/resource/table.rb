module KintoneSDK

  module Resource

    class Table

      include Enumerable

      def initialize(code, rows, type = nil)
        @table_code = code
        @type = type || :SUBTABLE
        @rows = parse_rows(rows)
      end
      attr_reader :table_code, :type

      def value
        @rows.map(&:value)
      end

      def field_code
        [@table_code, field_codes]
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

  end # module Resource

end # module KintoneSDK
