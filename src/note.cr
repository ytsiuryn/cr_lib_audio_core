require "json"

# Комментарии к метаданным.
class Notes
  include Enumerable(String)
  include JSON::Serializable
  delegate :<<, :delete, :each, :empty?, :size, :to_json, to: @notes

  def initialize(@notes = Set(String).new); end

  def self.new(pull : JSON::PullParser)
    new.tap do |notes|
      pull.read_array { notes << pull.read_string }
    end
  end
end

# Аггрегирующий набор комментариев с частотой их появления.
class FreqNotes
  include Enumerable({String, Int32})
  delegate :each, to: @storage

  def initialize(@storage = {} of String => Int32); end

  def with_frequency(freq : Int32) : Array(String)
    @storage.compact_map { |k, frequency| k if frequency == freq }
  end

  def merge(notes : Notes)
    notes.each { |note| @storage[note] = @storage.fetch(note, 0) + 1 }
  end
end
