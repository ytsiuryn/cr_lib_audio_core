require "json"

require "../actor"
require "../mood"
require "../utils"

enum RecordIdType
  UNKNOWN
  ISRC # международный код записи
  DISCOGS
  MUSICBRAINZ
end

json_serializable_enum RecordIdType

alias ID = String
alias Genres = Set(String)

class RecordIDs
  include JSON::Serializable
  include Enumerable({RecordIdType, ID})

  def initialize(@ids = Hash(RecordIdType, ID).new)
  end

  delegate :[], :[]=, :each, :size, :empty?, :has_key?, :fetch, to: @ids
end

# Сведения о записи композиции.
class Record
  include JSON::Serializable
  property genres, ids, moods, notes, roles

  def initialize
    @roles = Roles.new
    @moods = Moods.new
    @genres = Set(String).new
    @ids = RecordIDs.new
    @notes = Set(String).new
  end

  def add_role(name : String, role : String)
    @roles.add_role(name, role)
  end

  def empty? : Bool
    @roles.empty? && @moods.empty? && @genres.empty? && @ids.empty? && @notes.empty?
  end
end

class FreqGenres
  include Enumerable({String, Int32})

  def initialize
    @storage = Hash(String, Int32).new
  end

  delegate :each, to: @storage

  def with_frequency(freq : Int32) : Array(String)
    @storage.compact_map { |k, frequency| k if frequency == freq }
  end

  def merge(genres : Genres)
    genres.each { |genre| @storage[genre] = @storage.fetch(genre, 0) + 1 }
  end
end
