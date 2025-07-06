require "json"

require "./lyrics"
require "../actor"
require "../utils"

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

  def initialize
    @storage = Hash(CompositionIdType, CompositionID).new
  end

  # Делегируем основные методы Hash
  delegate :[], :[]=, :each, :size, :empty?, :has_key?, :fetch, to: @storage
end

# Музыкальная композиция.
class Composition
  include JSON::Serializable
  property ids, lyrics, notes, roles

  def initialize
    @roles = Roles.new
    @notes = Set(String).new
    @lyrics = Lyrics.new
    @ids = CompositionIDs.new
  end

  def add_role(actor : String, role : String)
    @roles.add_role(actor, role)
  end

  def empty? : Bool
    @roles.empty? && @notes.empty? && @lyrics.empty? && @ids.empty?
  end

  # Установка значения ID внешней БД.
  #
  # c = Composition()
  # c.set_id("ISWC", "12345") # => <CompositionIdType.ISWC: 1>
  # c.set_id("IS_WC", "12345") # => <CompositionIdType.UNKNOWN: 0>
  def set_id(k : String, v : String) : CompositionIdType
    id_type = CompositionIdType.parse?(k)
    if !is.nil?
      @ids[id_type] = v
    else
      id_type = CompositionIdType::UNKNOWN
    end
    id_type
  end
end
