require "json"
require "levenshtein"
require "../actor"
require "./audio"
require "./composition"
require "../generic"
require "../id"
require "../json"
require "../note"
require "./record"
require "../unprocessed"

# Информация о файле трека.
record FileInfo,
  fname : String = "",
  mtime : Int64 = 0,
  fsize : Int64 = 0 do
  include JSON::Serializable

  def empty? : Bool
    !File.file?(@fname) && @mtime == 0 && @fsize == 0
  end
end

# Общие метаданные, аудио- и файловые свойства трека.
class Track
  include JSON::Serializable

  property ainfo, composition, finfo, genres, ids, index, moods, notes, record, roles, title, unprocessed
  property disc_num : Int32, position : String
  @ainfo = AudioInfo.new
  @composition = Composition.new
  @disc_num = 0
  @finfo = FileInfo.new
  @moods = Moods.new
  @genres = Set(String).new
  @ids = IDs.new
  @index = -1 # парадкавы нумар, карыстуецца для параўнання
  @notes = Notes.new
  @position = ""
  @record = Record.new
  @roles = Roles.new
  @title = ""
  @unprocessed = Unprocessed.new

  def initialize(pos : String = "", index : Int32 = -1, path : String = "")
    @position = Track.normalize_pos(pos) # прэдстаўленне для чалавека
    @disc_num = Track.disc_num_by_track_pos(@position)
    unless path.empty?
      fi = File.info(path)
      @finfo = FileInfo.new(fname: path, mtime: fi.modification_time.to_unix, fsize: fi.size)
    end
  end

  # Формирование префикса имени файла на основании номера диска и позиции трека в альбоме.
  # assert complex_position("1", "2") == "1.2"
  def self.complex_position(pos : String, subpos : String) : String
    "#{pos}.#{subpos}"
  end

  # Формирование заголовка трека с учетом подзаголовка.
  # complex_title("Sym.5 in C minor, op.67", "1. Allegro con brio") # => # 'Sym.5 in C minor, op.67. 1. Allegro con brio'
  def self.complex_title(title : String, subtitle : String) : String
    "#{title}. #{subtitle}"
  end

  # Disc number from track position.
  #
  # Examples:
  # - [CD ("disk-track")](https://api.discogs.com/releases/2528044),
  # - [LP ("A,B,C,D,..")](https://api.discogs.com/releases/2373051)
  #  и [other](https://api.discogs.com/releases/13452282)
  #
  # Track.disc_num_by_track_pos("C3")    # => 2
  # Track.disc_num_by_track_pos("")      # => 1
  # Track.disc_num_by_track_pos("2.10")  # => 2
  # Track.disc_num_by_track_pos("3 - 1") # => 3
  def self.disc_num_by_track_pos(tpos : String) : Int32
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
  # ```
  # Track.disc_track_num_from_pos('A1') -- ValueError
  # Track.disc_track_num_from_pos('1 - 2') # => (1, 2)
  # Track.disc_track_num_from_pos('1.2') # => (1, 2)
  # Track.disc_track_num_from_pos('2') # => (1, 2)
  # ```
  def self.disc_track_num_from_pos(tpos : String) : Tuple(Int32, Int32)
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
  def self.normalize_pos(pos : String) : String
    return "0#{pos}" if pos.size == 1 && pos[0].number?
    pos
  end

  def compare(other : self) : Float64
    1.0 - Levenshtein.distance(@title, other.title) / 100
  end

  def aggregate_genres(f : FrequencyCounter(String))
    f.merge(@record.genres)
  end

  def aggregate_notes(f : FrequencyCounter(String))
    f.merge(@notes)
  end

  def aggregate_unprocessed(fu : FrequencyCounter({TagName, TagVal}))
    fu.merge(@unprocessed)
  end
end

# Коллекция треков.
class Tracks
  include JSON::Serializable
  include Enumerable(Track)
  delegate :[], :[]=, :<<, :each, :size, :to_json, to: @tracks

  property tracks : Array(Track)

  def initialize(@tracks = [] of Track); end

  def self.new(pull : JSON::PullParser)
    new.tap do |tracks|
      pull.read_array { tracks << Track.new(pull) }
    end
  end

  def [](index : Int)
    @tracks[index]? || raise "No track at index #{index}"
  end

  # Сравнение треков двух релизов с определением степени их схожести.
  def compare(other : self) : Float64
    return 0.0 if @tracks.empty? || other.empty?
    acc = 0.0
    @tracks.each_with_index do |track1, i|
      if i < other.size
        acc += track1.compare(other[i])
      end
    end
    acc / @tracks.size
  end

  # Пересчет позіціонных індексов треков, іспользуемых для сравненія с другімі релізамі.
  #
  # Еслі `total_tracks` совпадает с размером коллекціі, індекс будет соответствовать позіціі
  # трека в коллекціі.
  #
  # Еслі тіпом медіа является любой, кроме `LP`, в коллекціі с неполным чіслом треков
  # позіція определяется із номера трека.
  def calc_indexes
    @tracks.each_with_index do |track, i|
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
    @tracks.max_by(&.finfo.mtime).finfo.mtime
  end

  # Поиск трека в коллекции по его позиции.
  #
  # trs = Tracks()
  # trs.track("01") # => nil
  # t = Track("1")  # дополнительно проводится нормализация позиции
  # trs << t
  # trs.track("01") # not nil
  def track(pos : String) : Track | Nil
    @tracks.find { |track| track.position == pos }
  end

  # Преобразование позиции вида "A2 to B3" в последовательность позиций "A2", ... "B1", "B2", "B3".
  # def to_range(pos : String, delimiter : String = " to ") : Array(String)
  #   # p = pos.split(/,( to )/).map(&.strip)
  #   pp! pos.split(delimiter).flat_map { |el| el.split(',') }
  #   p = pos.split(delimiter).flat_map { |el| el.split(',') }.flat_map(&.strip)
  #   pp! p
  #   return [pos] if p.size != 2
  #   min, max = p.minmax
  #   @tracks.compact_map { |track| track.position if track.position >= min && track.position <= max }
  # end

  def to_range(pos : String, delimiter : String = " to ") : Array(String)
    # Если строка содержит `delimiter` внутри, но не является простым диапазоном (например, "A2 to B2 to C1")
    if pos.includes?(delimiter) && pos.split(/\s*to\s*/).size > 2
      return [pos]
    end

    result = [] of String

    # Разделяем по запятым, игнорируя запятые внутри "to"-диапазонов
    parts = pos.split(/,(?![^,]*to)/).map(&.strip)

    parts.each do |part|
      if part.includes?(delimiter)
        start_pos, end_pos = part.split(/\s*to\s*/).map(&.strip)
        start_idx = @tracks.index { |t| t.position == start_pos } || 0
        end_idx = @tracks.index { |t| t.position == end_pos } || @tracks.size - 1

        if start_idx && end_idx
          (start_idx..end_idx).each do |i|
            result << @tracks[i].position if i < @tracks.size
          end
        end
      else
        # Просто добавляем позицию, если она существует
        if @tracks.any? { |t| t.position == part }
          result << part
        end
      end
    end

    result
  end
end
