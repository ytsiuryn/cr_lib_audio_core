require "json"

require "./utils"

alias OnlineID = String

# Перечень внешних БД для ссылки на их идентификаторы."""
enum OnlineDB
  UNKNOWN
  DISCOGS
  MUSICBRAINZ
end

json_serializable_enum OnlineDB

class IDs
  include JSON::Serializable
  include Enumerable({OnlineDB, OnlineID})
  delegate :[], :[]=, :each, :size, :empty?, :has_key?, to: @ids

  def initialize
    @ids = Hash(OnlineDB, OnlineID).new
  end
end
