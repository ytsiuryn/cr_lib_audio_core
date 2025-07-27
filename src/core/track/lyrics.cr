# Текст песенных треков.

require "json"

# Список сервисов:
# https://www.programmableweb.com/category/lyrics/api
struct Lyrics
  include JSON::Serializable
  property text, lng, is_synced
  @text : String = ""
  @lng : String = "" # 3-символьное обозначение
  @is_synced : Bool = false

  def initialize; end

  def empty? : Bool
    @text.empty? && @lng.empty?
  end
end
