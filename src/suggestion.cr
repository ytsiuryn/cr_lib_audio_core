require "./release"
require "./id"

# Используется внешними сервисами для хранения единичного результата.
class Suggestion
  include JSON::Serializable
  property app, r, similarity

  def initialize
    @r = Release.new
    @app = OnlineDB::UNKNOWN
    @similarity = 0.0
  end
end

# Список предложений альбомов по результатам поиска во внешних БД.
class Suggestions
  include JSON::Serializable
  include Enumerable(Suggestion)

  def initialize(@sgs : Array(Suggestion) = [] of Suggestion)
  end

  delegate :[], :<<, :each, :size, to: @sgs

  # Оптимизирует релиз-данные для каждого результата и аггрегирует коды
  # акторов во внешних БД в поле Actors.
  def optimize
    @sgs.each(&.optimize)
  end

  # Удаленіе предложеній с балламі схожесті меньше указанных.
  def shrink_for_bigger_score(score : Float64)
    @sgs.reject! { |suggestion| suggestion.similarity <= score }
  end

  def shrink_to_best_results(n : Int32) : Suggestions
    best = @sgs.sort_by(&.similarity).reverse!.first(n)
    Suggestions.new(best)
  end
end
