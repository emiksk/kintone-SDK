module KintoneSDK

  module Resource

    class Field

      def self.create(code, value, type = nil)
        if value.is_a?(Array) && (type == nil || type == :SUBTABLE)
          Table.new(code, value, type)
        else
          Field.new(code, value, type)
        end
      end

      def initialize(code, val, type = :UNKNOWN)
        @field_code = code
        @value = val
        @type = type
      end
      attr_accessor :field_code, :value, :type

      def request_body_format(for_update = nil)
        {value: @value}
      end

    end # class Field

  end # module Resource

end # module KintoneSDK
