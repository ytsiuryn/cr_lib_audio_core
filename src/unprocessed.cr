alias TagName = String
alias TagVal = String

# Теги аудиофайлов, не прошедшие обработку.
alias Unprocessed = Hash(TagName, TagVal)

# Аггрегирующий набор необработанных тэгов с частотой их появления.
class FreqUnprocessed
  include Enumerable({Tuple(TagName, TagVal), Int32})

  def initialize
    @storage = Hash(Tuple(TagName, TagVal), Int32).new
  end

  delegate :each, to: @storage

  def with_frequency(freq : Int32) : Unprocessed
    Unprocessed.new.tap do |result|
      @storage.each do |(name, val), count|
        result[name] = val if count == freq
      end
    end
  end

  def merge(m : Unprocessed)
    m.each do |name, val|
      key = {name, val}
      @storage[key] = @storage.fetch(key, 0) + 1
    end
  end
end
