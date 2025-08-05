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
