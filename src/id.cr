require "json"

require "./json"

alias OnlineID = String

# Перечень внешних БД для ссылки на их идентификаторы."""
enum OnlineDB
  UNKNOWN
  DISCOGS
  MUSICBRAINZ
end

json_serializable_enum OnlineDB

# Идентификаторы во внешних БД.
class IDs
  include JSON::Serializable
  include Enumerable({OnlineDB, OnlineID})
  delegate :[], :[]=, :each, :size, :empty?, :has_key?, :to_json, to: @ids

  def initialize(@ids = {} of OnlineDB => OnlineID); end

  def self.new(pull : JSON::PullParser)
    new.tap do |ids|
      pull.read_object do |key|
        db = OnlineDB.parse(key)
        ids[db] = pull.read_string
      end
    end
  end
end
