require "json"
require "time"

# Аудио свойства файла трека.
record AudioInfo,
  channels : Int32 = 0,
  samplesize : Int32 = 0,
  samplerate : Int32 = 0,
  avg_bitrate : Int32 = 0,
  duration : Int64 = 0 do # в ms
  include JSON::Serializable

  # Преобразование из строки вида 'HH:MM:SS'
  # Возвращает `true` в случае успеха преобразования.
  def duration_from_str=(s : String)
    time = Time.parse(s, "%H:%M:%S", Time::Location::UTC)
    @duration = Time::Span.new(
      hours: time.hour,
      minutes: time.minute,
      seconds: time.second,
      nanoseconds: 0
    ).total_milliseconds.to_i64
  rescue Time::Format::Error
    raise Time::Format::Error.new("Invalid time format. Expected HH:MM:SS")
  end

  def empty? : Bool
    @channels == 0 && @samplesize == 0 && @samplerate == 0 && @avg_bitrate == 0 && @duration == 0
  end
end
