macro json_serializable_enum(*names)
  {% for name in names %}
    enum {{name}}
      def to_json(builder : JSON::Builder)
        builder.scalar(to_s)
      end

      def self.from_json(pull : JSON::PullParser)
        parse(pull.read_string)
      end

      # Для использования в качестве ключей Hash
      def to_json_object_key
        to_s
      end

      # Добавляем метод для парсинга ключей Hash
      def self.from_json_object_key?(key : String)
        parse(key)
      rescue ArgumentError
        nil
      end
    end
  {% end %}
end

module JsonHelpers
  private def json_field(builder, name, value)
    case value
    when Time then builder.field(name, value.to_rfc3339)
    when Enum then builder.field(name, value.to_s)
    else           builder.field(name, value)
    end
  end
end
