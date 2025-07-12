require "json"

require "./json"
require "./note"

# Тип внедренного в файл трека изображения.
enum PictType
  UNKNOWN
  PNG_ICON
  OTHER_ICON
  COVER_FRONT
  COVER_BACK
  LEAFLET
  MEDIA
  LAD_ARTIST
  ARTIST
  CONDUCTOR
  ORCHESTRA
  COMPOSER
  LYRICIST
  RECORDING_LOCATION
  DURING_RECORDING
  DURING_PERFORMANCE
  MOVIE_SCREEN
  BRIGHT_COLOR_FISH
  ILLUSTRATION
  ARTIST_LOGOTYPE
  PUBLISHER_LOGOTYPE

  def empty? : Bool
    self == PictType::UNKNOWN
  end
end

json_serializable_enum PictType

# Общие метаданные изображения.
struct PictureMetadata
  include JSON::Serializable

  property colors, color_depth, height, mime, width

  def initialize
    @mime = ""
    @width = 0
    @height = 0
    @color_depth = 0
    @colors = 0
  end

  # Проверка является ли объект пустым.
  #
  # ```
  # PictureMetadata().empty? # => true
  # ```
  def empty? : Bool
    !(@mime || @width || @height || @color_depth || @colors)
  end
end

# Внедренное в файл трека изображение.
class PictureInAudio
  include JSON::Serializable

  @[JSON::Field(ignore: true)]
  property data = Bytes.empty
  property md = PictureMetadata.new
  property notes = Notes.new
  property pict_type = PictType::UNKNOWN
  property url = ""

  def initialize(@pict_type : PictType); end
end

# Свойства изображения для аудио (альбомы, исполнители, ...)
class PicturesInAudio
  include JSON::Serializable
  include Enumerable(PictureInAudio)
  delegate :[], :<<, :each, :size, :to_json, to: @pictures

  def initialize(@pictures = [] of PictureInAudio); end

  def self.new(pull : JSON::PullParser)
    new.tap do |pictures|
      pull.read_array { pictures << PictureInAudio.new(pull) }
    end
  end
end
