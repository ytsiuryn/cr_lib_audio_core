require "json"

require "./utils"

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
class PictureMetadata
  include JSON::Serializable
  property mime, width, height, color_depth, colors

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
  property md, notes, url
  getter pict_type : PictType

  @[JSON::Field(ignore: true)] # Полностью исключаем из JSON
  property data : Slice(UInt8) = Slice(UInt8).empty

  def initialize(@pict_type : PictType)
    @md = PictureMetadata.new
    @notes = Set(String).new
    @url = ""
  end
end

class PicturesInAudio
  include JSON::Serializable
  include Enumerable(PictureInAudio)
  delegate :[], :<<, :each, :size, to: @pictures

  def initialize
    @pictures = Array(PictureInAudio).new
  end
end
