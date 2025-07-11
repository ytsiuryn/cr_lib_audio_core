# Текст песенных треков.

require "json"

# Список сервисов:
# https://www.programmableweb.com/category/lyrics/api
record Lyrics,
  text : String = "",
  lng : String = "", # 3-символьное обозначение
  is_synced : Bool = false do
  include JSON::Serializable

  def empty? : Bool
    @text.empty? && @lng.empty?
  end
end
