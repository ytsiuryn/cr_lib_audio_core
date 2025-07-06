require "json"

require "../actor"
require "./audio"
require "./composition"
require "../note"
require "../id"
require "./record"
require "../unprocessed"
require "../utils"

# Формирование префикса имени файла на основании номера диска и позиции трека
# в альбоме.
# assert complex_position("1", "2") == "1.2"
def complex_position(pos : String, subpos : String) : String
  "#{pos}.#{subpos}"
end

# Формирование заголовка трека с учетом подзаголовка.
# complex_title("Sym.5 in C minor, op.67", "1. Allegro con brio") # => # 'Sym.5 in C minor, op.67. 1. Allegro con brio'
def complex_title(title : String, subtitle : String) : String
  "#{title}. #{subtitle}"
end

# Disc number from track position.
# Examples:
# [CD ("disk-track")](https://api.discogs.com/releases/2528044),
# [LP ("A,B,C,D,..")](https://api.discogs.com/releases/2373051)
#  и [other](https://api.discogs.com/releases/13452282)
#
# disc_num_by_track_pos('C3')    # => 2
# disc_num_by_track_pos('')      # => 1
# disc_num_by_track_pos('2.10')  # => 2
# disc_num_by_track_pos('3 - 1') # => 3
def disc_num_by_track_pos(tpos : String) : Int32
  return 1 if tpos.empty?
  pos = tpos.delete(" ").gsub('-', '.') # tpos.match(/\s|-/, ".")
  flds = pos.split(".")
  if flds.size == 2
    begin
      d = flds[0].to_i
    rescue ArgumentError
      d = 1
    end
    return d
  end
  c = pos[0]
  return 1 if c < 'A'
  diff = c.ord - 'A'.ord
  return (diff / 2).to_i32 + 1 if diff < 128
  1
end

# Disc and track numbers from track position.
#
# disc_track_num_from_pos('A1') -- ValueError
# disc_track_num_from_pos('1 - 2') # => (1, 2)
# disc_track_num_from_pos('1.2') # => (1, 2)
# disc_track_num_from_pos('2') # => (1, 2)
def disc_track_num_from_pos(tpos : String) : Tuple(Int32, Int32)
  pos = tpos.gsub(/\s|-/, ".")
  flds = pos.split(".")
  case flds
  when [String, String]
    {flds[0].to_i, flds[1].to_i}
  when [String]
    flds[0].match(/\d+/) ? {1, flds[0].to_i} : raise ArgumentError.new("Incorrect track position")
  else
    raise ArgumentError.new("Incorrect track position")
  end
end

# Returns a correct form of track position representation.
def normalize_pos(pos : String) : String
  return "0#{pos}" if pos.size == 1 && pos[0].number?
  pos
end

# Информация о файле трека.
class FileInfo
  include JSON::Serializable
  property fname, mtime, fsize

  def initialize
    @fname = ""
    @mtime = 0
    @fsize = 0
  end

  def empty? : Bool
    !File.file?(@fname) && @mtime == 0 && @fsize == 0
  end
end

# Общие метаданные, аудио- и файловые свойства трека.
class Track
  include JSON::Serializable
  property ainfo, composition, finfo, genres, ids, index, notes, position, record, title, unprocessed
  @position : String

  def initialize(pos : String = "", index : Int32 = -1)
    @disc_num = 0                  # disc_num_by_track_pos(pos)
    @position = normalize_pos(pos) # прэдстаўленне для чалавека
    @index = index                 # парадкавы нумар, карыстуецца для параўнання
    @composition = Composition.new
    @record = Record.new
    @title = ""
    @notes = Notes.new
    @roles = Roles.new
    @ids = IDs.new
    @unprocessed = Unprocessed.new
    @finfo = FileInfo.new
    @ainfo = AudioInfo.new
  end

  def compare(other : self) : Float64
    1.0 - levenshtein_distance(@title, other.title) / 100
  end

  def aggregate_genres(f : FreqGenres)
    f.merge(@record.genres)
  end

  def aggregate_notes(f : FreqNotes)
    f.merge(@notes)
  end

  def aggregate_unprocessed(fu : FreqUnprocessed)
    fu.merge(@unprocessed)
  end

  # Установка позиции трека в альбоме.
  # Дополнительно проводится нормализация значения позиции и установка номера диска.
  def position=(pos : String)
    @disc_num = disc_num_by_track_pos(pos)
    @position = normalize_pos(pos)
  end
end

# Коллекция треков.
class Tracks
  include JSON::Serializable
  include Enumerable(Track)
  delegate :[], :<<, :each, :size, to: @ts

  def initialize
    @ts = Array(Track).new
  end

  # Сравнение треков двух релизов с определением степени их схожести.
  def compare(other : self) : Float64
    return 0.0 if @ts.empty? || other.empty?
    acc = 0.0
    @ts.each_with_index do |track1, i|
      if i < other.size
        acc += track1.compare(other[i])
      end
    end
    acc / @ts.size
  end

  # Пересчет позіціонных індексов треков, іспользуемых для сравненія с другімі релізамі.
  #
  # Еслі `total_tracks` совпадает с размером коллекціі, індекс будет соответствовать позіціі
  # трека в коллекціі.
  #
  # Еслі тіпом медіа является любой, кроме `LP`, в коллекціі с неполным чіслом треков
  # позіція определяется із номера трека.
  def calc_indexes
    @ts.each_with_index do |track, i|
      if track.index == -1
        if track.position >= "A"
          next
        end
        track.index = i - 1
      end
    end
  end

  # Вяртае наібольшую дату мадыфікацыі трэкаў.
  def last_modified
    @ts.max_by(&.finfo.mtime).finfo.mtime
  end

  # Поиск трека в коллекции по его позиции.
  #
  # trs = Tracks()
  # trs.track('01') # => nil
  # t = Track("1")  # дополнительно проводится нормализация позиции
  # trs.append(t)
  # trs.track('01') # not nil
  def track(pos : String) : Track | Nil
    @ts.find { |track| track.position == pos }
  end

  # Преобразование позиции вида "A2 to B3" в последовательность позиций "A2", ... "B1", "B2", "B3".
  def to_range(pos : String, delimiter : String = " to ") : Array(String)
    p = pos.split(delimiter)
    return [pos] if p.size != 2
    min, max = p.minmax
    @ts.compact_map { |track| track.position if track.position >= min && track.position <= max }
  end
end
