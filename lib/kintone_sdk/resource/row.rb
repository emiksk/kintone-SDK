module KintoneSDK

  module Resource

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
        @fields.field_codes
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
        @fields[key.to_s] = Field.new(key.to_s, val)
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

      def parse_fields(hash)
        fields = Fields.new
        hash.each do |key, field|
          fields.set_field(key.to_s, field["value"], field["type"]&.to_sym)
        end
        fields
      end

    end # class Row

  end # module Resource

end # module KintoneSDK
