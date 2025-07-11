require "json"
require "levenshtein"

require "../actor"
require "./disc"
require "../genre"
require "../id"
require "../mood"
require "../note"
require "../picture"
require "./publishing"
require "./props"
require "../track"
require "../unprocessed"

enum ReleaseIdType
  UNKNOWN
  BARCODE # Amazon Standard Identification Number
  ACCURATE_RIP
  ASIN
  DISCOGS
  MUSICBRAINZ
  MUSICBRAINZ_RELEASE_GROUP
  RUTRACKER
  UPC
end

json_serializable_enum ReleaseIdType

alias ReleaseID = String

class ReleaseIDs
  include JSON::Serializable
  include Enumerable({ReleaseIdType, ReleaseID})
  delegate :[], :[]=, :each, :size, :empty?, :has_key?, :to_json, to: @ids

  def initialize(@ids = {} of ReleaseIdType => ReleaseID); end

  def self.new(pull : JSON::PullParser)
    new.tap do |ids|
      pull.read_object do |key|
        id_type = ReleaseIdType.parse(key)
        ids[id_type] = pull.read_string
      end
    end
  end
end

# Происхождение и физическое представление альбома.
class Release
  include JSON::Serializable

  property discs = Discs.new
  property issues = Issues.new
  property genres = Set(String).new
  property ids = ReleaseIDs.new
  property notes = Notes.new
  property origin = ReleaseOrigin::UNKNOWN
  property pictures = PicturesInAudio.new
  property remake = ReleaseRemake::UNKNOWN
  property repeat = ReleaseRepeat::UNKNOWN
  property status = ReleaseStatus::UNKNOWN
  property title = ""
  property total_discs = 0
  property total_tracks = 0
  property tracks = Tracks.new
  property type = ReleaseType::ALBUM
  property unprocessed = Unprocessed.new
  getter actors = ActorIDs.new
  getter roles = Roles.new

  def initialize; end

  # Сравнивает два объекта Release по важным метаданным.
  # Если номера каталогов изданий совпадают, объекты считаются идентичными без учета др. данных.
  # Перед выполненіем сравненіе проводітся расчет індексов треков.
  def compare(other : self) : Float64
    @tracks.calc_indexes
    lbl = pub_compare(other)
    return 1.0 if lbl == 1.0
    t = Levenshtein.distance(self.title, other.title) / 100
    return 0.0 if t == 0.0
    p = performers_compare(other)
    tr = @total_tracks != other.total_tracks ? 0.0 : @tracks.compare(other.tracks)
    return 0.0 if tr == 0.0
    d = @total_discs != other.total_discs ? 0.0 : @discs.compare(other.discs)
    (5.0 * t + 5.0 * p + lbl + tr + d) / (5.0 + 5.0 + 1.0 + 1.0 + 1.0)
  end

  # Добавление актора в словарь идентификаторов внешней БД.
  def add_actor(actor : String, ext_db : String, id : String)
    if !@actors.includes?(actor)
      @actors[actor] = IDs.new
    end
    @actors[actor][OnlineDB.parse(ext_db)] = id
  end

  # Добавить роль для актора релиза.
  def add_role(actor : String, role : String = "performer")
    @roles.add(actor, role)
  end

  def aggregate_actors
    counter = Hash({Name, String}, Int32).new(0)
    tracks_count = @tracks.size
    @tracks.each do |track|
      # Объединенный сбор ролей
      [track.record.roles, track.composition.roles].each do |roles_collection|
        roles_collection.each do |actor, roles|
          roles.each do |role|
            counter[{actor, role}] += 1
          end
        end
      end
    end
    # Однопроходная обработка
    counter.each do |(actor, role), count|
      if count == tracks_count
        add_role(actor, role)
        @tracks.each do |track|
          track.record.roles.delete(actor, role)
          track.composition.roles.delete(actor, role)
        end
      end
    end
  end

  def aggregate_genres
    f = FreqGenres.new
    @tracks.each(&.aggregate_genres(f))
    f.with_frequency(@tracks.size).each do |genre|
      @genres << genre
      @tracks.each(&.record.genres.delete(genre))
    end
  end

  def aggregate_notes
    f = FreqNotes.new
    @tracks.each(&.aggregate_notes(f))
    f.with_frequency(@tracks.size).each do |note|
      @notes << note
      @tracks.each(&.notes.delete(note))
    end
  end

  def aggregate_unprocessed
    fu = FreqUnprocessed.new
    @tracks.each(&.aggregate_unprocessed(fu))
    fu.with_frequency(@tracks.size).each do |k, v|
      @unprocessed[k] = v
      @tracks.each(&.unprocessed.delete(k))
    end
  end

  # Определяет степень заполненности объекта важными метаданными значением в диапазоне [0..1].
  #
  # Для определения значения учитывается наличие исполнителя релиза, а также
  # сведения об издании, треках и дисках.
  #
  # Отсутствие сведений об основных исполнителях альбома расценивается как
  # отсутствие метаданных, потому что это не позволяет проводить поиск уточняющей
  # информации в online базах данных.
  def charging : Float64
    (!@title.empty? ? 0.4 : 0.0) +
      (@roles.performers.size > 0 ? 0.2 : 0.0) +
      (@tracks.size > 0 ? 0.2 : 0.0) +
      (@issues.actual.labels.size > 0 ? 0.1 : 0.0) +
      (@discs.size > 0 ? 0.1 : 0.0)
  end

  # Список настроений релиза из треков.
  def moods : Moods
    Moods.new(@tracks.flat_map(&.moods.to_a))
  end

  # Определение наличия обязательных атрибутов.
  def no_mandatory_fields : Bool
    @title.empty? || @roles.performers.empty? || @tracks.empty? || @issues.actual.labels.empty?
  end

  # Паменьшэнне займаемых абъектамі метаданных абъема памяці за кошт аггрэгацыі
  # аднолькавых значенняў на ўзровень вышэй.
  def optimize
    aggregate_actors
    aggregate_genres
    aggregate_notes
    aggregate_unprocessed
  end

  def performers_compare(other : self) : Float64
    @roles.performers.compare(other.roles.performers)
  end

  # Поиск изображения в коллекции по ее типу.
  def picture(pt : PictType) : PictureInAudio | Nil
    @pictures.find { |pict| pict.pict_type == pt }
  end

  # Перечень всех типов внедренных в трек изображений.
  def picture_types : Set(PictType)
    @pictures.map(&.pict_type).to_set
  end

  def pub_compare(other : self) : Float64
    return 0.0 if @issues.actual.labels.empty? || other.issues.actual.labels.empty?
    ret = 0.0
    @issues.each do |publ|
      other.issues.each do |publ2|
        res = publ.compare(publ2)
        return 1.0 if res == 1.0
        ret = Math.max(ret, res)
      end
    end
    ret
  end
end
