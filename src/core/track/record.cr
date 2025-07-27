require "json"
require "../actor"
require "../genre"
require "../json"
require "../mood"
require "../note"

# Перечень внешних БД для описания аудио записей.
enum RecordIdType
  UNKNOWN
  ISRC # международный код записи
  DISCOGS
  MUSICBRAINZ
end

json_serializable_enum RecordIdType

alias ID = String

# Описание идентификаторов для записи во внешних БД.
class RecordIDs
  include JSON::Serializable
  include Enumerable({RecordIdType, ID})
  delegate :[], :[]=, :each, :size, :empty?, :has_key?, :fetch, :to_json, to: @ids

  property ids = {} of RecordIdType => ID

  def initialize; end

  def initialize(pull : JSON::PullParser)
    pull.read_object do |key|
      id_type = RecordIdType.parse(key)
      @ids[id_type] = pull.read_string
    end
  end
end

# Сведения о записи композиции.
class Record
  include JSON::Serializable

  property ids, notes, roles
  @roles = Roles.new
  @ids = RecordIDs.new
  @notes = Notes.new

  def initialize; end

  def add_role(name : String, role : String)
    @roles.add(name, role)
  end

  def empty? : Bool
    @roles.empty? && @ids.empty? && @notes.empty?
  end
end
