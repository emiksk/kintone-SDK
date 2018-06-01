module KintoneSDK

  module Resource

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

  end # module Resource

end # module KintoneSDK
