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
