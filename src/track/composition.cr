require "json"

require "../actor"
require "../json"
require "./lyrics"
require "../note"

enum CompositionIdType
  UNKNOWN0 # International Standard Work Code
  ISWC     # International Standard Audiovisual Number
  ISAN     # международный код для аудио-визуальных произведений
  # International Standard Music Number (ISMN)
end

json_serializable_enum CompositionIdType

alias CompositionID = String

class CompositionIDs
  include JSON::Serializable
  include Enumerable({CompositionIdType, CompositionID})
  delegate :[], :[]=, :each, :size, :empty?, :has_key?, :fetch, :to_json, to: @ids

  def initialize(@ids = {} of CompositionIdType => CompositionID); end

  def initialize(pull : JSON::PullParser)
    @ids = {} of CompositionIdType => CompositionID
    pull.read_object do |key|
      id_type = CompositionIdType.parse(key)
      @ids[id_type] = pull.read_string
    end
  end
end

# Музыкальная композиция.
class Composition
  include JSON::Serializable

  property ids, lyrics, notes, roles
  @roles = Roles.new
  @notes = Notes.new
  @lyrics = Lyrics.new
  @ids = CompositionIDs.new

  def initialize; end

  def add_role(actor : String, role : String)
    @roles.add(actor, role)
  end

  def empty? : Bool
    @roles.empty? && @notes.empty? && @lyrics.empty? && @ids.empty?
  end

  # Установка значения ID внешней БД.
  #
  # c = Composition.new
  # c.add_id("ISWC", "12345") # => <CompositionIdType::ISWC: 1>
  # c.add_id("IS_WC", "12345") # => <CompositionIdType::UNKNOWN: 0>
  def add_id(k : String, v : String) : CompositionIdType
    id_type = CompositionIdType.parse?(k)
    if !is.nil?
      @ids[id_type] = v
    else
      id_type = CompositionIdType::UNKNOWN
    end
    id_type
  end
end
