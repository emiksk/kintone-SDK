module KintoneSDK

  class KintoneHTTPError < StandardError
    attr_reader :message_text, :id, :code, :http_status, :errors

    def initialize(messages, http_status)
      @message_text = messages['message']
      @id = messages['id']
      @code = messages['code']
      @errors = messages['errors']
      @http_status = http_status
      super(format('%s [%s] %s(%s)', @http_status, @code, @message_text, @id))
    end

  end #  class KintoneHTTPError

  class ReadOnlyError < StandardError
    attr_reader :field_code, :type

    def initialize(field_code, type)
      @field_code = field_code
      @type = type
      super(format("%s is read only field. This type is %s.", @field_code, @type))
    end
  end # class ReadOnlyError

    class ExistedRecordError < StandardError
    attr_reader :app_id, :record_id

    def initialize(app_id, record_id)
      @app_id = app_id
      @record_id = record_id
      super(format("This record(ID: %s in APP ID: %s) is already existed in kintone.", @record_id, @app_id))
    end
  end # class ReadOnlyError

end # module KintoneSDK
