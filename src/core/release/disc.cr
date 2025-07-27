require "json"
require "../json"

alias DiscID = String

# Перечень внешних БД для описания диска.
enum DiscIdType
  UNKNOWN
  DISC_ID
  MUSICBRAINZ
  DISCOGS
end

# Тип носителя аудиоданных релиза.
enum Media
  UNKNOWN
  SACD
  CD
  DIGITAL
  REEL
  LP

  def self.new(s : String) : self # TODO: переименовать в `parse`
    case s.downcase
    when "lp", "vinyl" then Media::LP
    when "sacd"        then Media::SACD
    when "cd"          then Media::CD
    when "digital", "[tr24][of]", "[tr24][sm][of]", "[dsd][of]", "[dxd][of]", "[dvda][of]"
      Media::DIGITAL
    when "reel" then Media::REEL
    else
      Media::UNKNOWN
    end
  end
end

json_serializable_enum DiscIdType, Media

# Описание диска во внешних БД.
class DiscIDs
  include JSON::Serializable
  include Enumerable({DiscIdType, DiscID})
  delegate :[], :[]=, :each, :size, :empty?, :has_key?, :fetch, :to_json, to: @discs

  def initialize(@discs = {} of DiscIdType => DiscID); end

  def initialize(pull : JSON::PullParser)
    @discs = {} of DiscIdType => DiscID
    pull.read_object do |key|
      id_type = DiscIdType.parse(key)
      @discs[id_type] = pull.read_string
    end
  end
end

# Формат диска и прочие свойства.
class DiscFormat
  include JSON::Serializable

  property attrs, media

  def initialize
    @media = Media::UNKNOWN
    @attrs = [] of String
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
  @fmt = DiscFormat.new
  @ids = DiscIDs.new
  @title = ""

  def initialize(@num : Int32 = 1)
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

# Перечень дисков релиза.
class Discs
  include JSON::Serializable
  include Enumerable(Disc)
  delegate :[], :each, :size, to_json, to: @discs

  def initialize
    @discs = [] of Disc
    @total = 0
  end

  def self.new(pull : JSON::PullParser)
    new.tap do |discs|
      pull.read_array { discs << Disc.new(pull) }
    end
  end

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
    d = find_by_num(disc.num)
    if d.nil?
      @discs << disc
    else
      d.merge_with(disc)
    end
  end
end
