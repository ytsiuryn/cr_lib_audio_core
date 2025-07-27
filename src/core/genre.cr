require "json"

alias Genres = Set(String)

module GenreParser
  def self.parse(pull : JSON::PullParser) : Set(String)
    Set(String).new.tap do |genres|
      pull.read_array do
        genres << pull.read_string
      end
    end
  end

  def self.to_json(genres : Set(String), builder : JSON::Builder)
    builder.array do
      genres.each { |genre| builder.string(genre.to_s) }
    end
  end
end

# Расчет счетчиков по всем жанрам для дальнейшей аггрегации на уровень выше.
class FreqGenres
  include Enumerable({String, Int32})
  delegate :each, to: @hash

  def initialize(@hash = {} of String => Int32); end

  def with_frequency(freq : Int32) : Array(String)
    @hash.compact_map { |k, frequency| k if frequency == freq }
  end

  def merge(genres : Genres)
    genres.each { |genre| @hash[genre] = @hash.fetch(genre, 0) + 1 }
  end
end
