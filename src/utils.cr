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

# Расстояние Левенштейна
#
# puts levenshtein_distance("кот", "код") # => 1
def levenshtein_distance(s, t)
  v0 = (0..t.size).to_a
  v1 = Array.new(t.size + 1, 0)

  s.each_char_with_index do |s_char, i|
    v1[0] = i + 1

    t.each_char_with_index do |t_char, j|
      cost = s_char == t_char ? 0 : 1
      v1[j + 1] = {v1[j] + 1, v0[j + 1] + 1, v0[j] + cost}.min
    end

    v0 = v1.dup
  end

  v0[t.size]
end
