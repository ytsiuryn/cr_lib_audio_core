require "json"

require "../utils"

alias DiscID = String

enum DiscIdType
  UNKNOWN
  DISC_ID
  MUSICBRAINZ
  DISCOGS
end

json_serializable_enum DiscIdType

class DiscIDs
  include JSON::Serializable
  include Enumerable({DiscIdType, DiscID})

  def initialize
    @discs = Hash(DiscIdType, DiscID).new
  end

  delegate :[], :[]=, :each, :size, :empty?, :has_key?, :fetch, to: @discs
end

# Тип носителя аудиоданных релиза.
enum Media
  UNKNOWN
  SACD
  CD
  DIGITAL
  REEL
  LP

  def self.from_str(s : String) : Media
    case s.to_down
    when "lp", "vinyl"
      Media::LP
    when "sacd"
      Media::SACD
    when "cd"
      Media::CD
    when "digital", "[tr24][of]", "[tr24][sm][of]", "[dsd][of]", "[dxd][of]", "[dvda][of]"
      Media::DIGITAL
    when "reel"
      Media::REEL
    else
      Media::UNKNOWN
    end
  end
end

json_serializable_enum Media

class DiscFormat
  include JSON::Serializable
  property attrs, media

  def initialize
    @media = Media::UNKNOWN
    @attrs = Array(String).new
  end

  def has_attr(attr : String) : Bool
    @attrs.any? { |attribute| attribute == attr }
  end

  def empty? : Bool
    @media == Media::UNKNOWN && @attrs.empty?
  end

  def compare(other : self) : Float64
    @media == other.media ? 1.0 : 0.0 # а если пустые?
  end
end

# Свойства диска. Сам номер диска указывается в объекте `Track`.
class Disc
  include JSON::Serializable
  property fmt, ids, num, title

  def initialize(@num : Int32 = 1)
    @fmt = DiscFormat.new
    # - "id" - код диска, установленный производителем
    @ids = DiscIDs.new
    @title = ""
  end

  def compare(other : self) : Float64
    @num != other.num ? 0.0 : @fmt.compare(other.fmt)
  end

  # Set disc properties with using other one.
  def merge_with(other : self)
    other.fmt.attrs.each { |attribute| @fmt.attrs << attribute }
    @title = other.title if other.title
    other.ids.each { |k, v| @ids[k] = v }
  end

  # TODO: определить есть ли БД по DiscID/CD_ID и, если да,
  # добавить их в online/OnlineDB для чтенія с from_str()
  def disc_id=(id : String)
    @ids[DiscIdType::DISC_ID] = id
  end
end

class Discs
  include JSON::Serializable
  include Enumerable(Disc)
  @[JSON::Field(key: "discs")]
  property discs : Array(Disc)

  def initialize
    @discs = Array(Disc).new
    @total = 0
  end

  delegate :[], :each, :size, to: @discs

  def compare(other : self) : Float64
    return 0.0 if @discs.empty? || other.empty?
    acc = 0.0
    @discs.each do |disc1|
      other.each do |disc2|
        if disc1.num == disc2.num
          acc += disc1.compare(disc2)
        end
      end
    end
    acc / @discs.size
  end

  def find_by_num(num : Int32) : Disc?
    @discs.find { |disc| disc.num == num }
  end

  # Добавляет диск в коллекцию, если он не существует. Иначе дополняет его свойства.
  def <<(disc : Disc)
    d_ = find_by_num(disc.num)
    if d_.nil?
      @discs << disc
    else
      d_.merge_with(disc)
    end
  end
end
