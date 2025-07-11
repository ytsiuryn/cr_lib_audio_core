require "./json"

# Настроение, переданное в музыкальной композиции.
enum Mood
  UNKNOWN     =   0
  HAPPY       =   1
  EXUBERANT   =   2
  ENERGETIC   =   4
  FRANTIC     =   8
  ANXIOUS_SAD =  16
  DEPRESSION  =  32
  CALM        =  64
  CONTENTMENT = 128
end

json_serializable_enum Mood

alias Moods = Set(Mood)

module MoodsParser
  def self.parse(pull : JSON::PullParser) : Moods
    Moods.new.tap do |moods|
      pull.read_array do
        moods << Mood.parse(pull.read_string)
      end
    end
  end

  def self.to_json(moods : Set(Mood), builder : JSON::Builder)
    builder.array do
      moods.each { |mood| builder.string(mood.to_s) }
    end
  end
end
