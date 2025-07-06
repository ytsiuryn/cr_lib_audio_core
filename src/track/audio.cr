require "json"
require "time"

# Аудио свойства файла трека.
class AudioInfo
  include JSON::Serializable
  property avg_bitrate, channels, channels, duration, samplesize, samplerate
  @duration : Time::Span

  def initialize
    @channels = 0
    @samplesize = 0
    @samplerate = 0
    @avg_bitrate = 0
    @duration = Time::Span::MIN
  end

  def duration_from_ms=(ms : Int)
    @duration = Time::Span.new(nanoseconds: ms * 1_000_000)
  end

  # Преобразование из строки вида 'HH:MM:SS'
  # Возвращает `true` в случае успеха преобразования.
  def duration_from_str(s : String) : Bool
    begin
      time = Time.parse(s, "%H:%M:%S", Time::Location::UTC)
      @duration = Time::Span.new(
        hours: time.hour,
        minutes: time.minute,
        seconds: time.second,
        nanoseconds: 0
      )
      true
    rescue Time::Format::Error
      false
    end
  end

  # Длительность в пересчете на миллисекунды.
  def ms : Float64
    @duration.total_milliseconds
  end

  def empty? : Bool
    @channels == 0 && @samplesize == 0 && @samplerate == 0 && @avg_bitrate == 0 && @duration == Time::Span::MIN
  end
end
