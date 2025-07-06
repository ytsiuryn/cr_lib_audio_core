# Текст песенных треков.

require "json"

# Список сервисов:
# https://www.programmableweb.com/category/lyrics/api
class Lyrics
  include JSON::Serializable
  property is_synced, lng, text

  def initialize(@text : String = "", @lng : String = "")
    # 3-символьное обозначение
    @is_synced = false
  end

  def empty? : Bool
    @text.empty? && @lng.empty?
  end
end
