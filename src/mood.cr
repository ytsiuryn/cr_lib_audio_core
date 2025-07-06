require "./utils"

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
