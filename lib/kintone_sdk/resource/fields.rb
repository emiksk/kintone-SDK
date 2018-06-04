module KintoneSDK

  module Resource

    class Fields

      include Enumerable

      def initialize
        @contents = {}
      end

      def [](key)
        @contents[key.to_s]&.value
      end

      def []=(key, val)
        raise KintoneSDK::ReadOnlyError.new(key, @contents[key.to_s]&.type) if READONLY_FIELDS.include?(@contents[key.to_s]&.type)
        @contents[key.to_s] = Field.create(key.to_s, val)
      end

      def get_field(key)
        @contents[key.to_s]
      end

      def set_field(key, value, type)
        @contents[key.to_s] = Field.create(key.to_s, value, type.to_sym)
      end

      def field_codes
        @contents.map { |k, v| v.field_code }.flatten
      end

      def field_values
        @contents.values.map(&:value)
      end

      def each
        @contents.each do |k, v|
          yield(k, v)
        end
      end

    end # class Fields

  end # module Resource

end # module KintoneSDK
