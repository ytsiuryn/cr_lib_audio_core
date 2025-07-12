require "json"

require "../id"
require "../note"

alias LabelName = String
alias CatNo = String

# Свойства торговой марки издания.
class Label
  include JSON::Serializable

  property catnos = Set(CatNo).new
  property ids = IDs.new
  property name = ""
  property notes = Notes.new

  def initialize(@name : String = ""); end

  def merge_with(other : self)
    other.catnos.each { |catno| @catnos << catno }
    other.ids.each { |k, v| @ids[k] = v }
    other.notes.each { |note| @notes << note }
  end
end

# Перечень торговых марок.
class Labels
  include JSON::Serializable
  include Enumerable(Label)
  delegate :[], :<<, :each, :size, :to_json, to: @labels

  def initialize(@labels = [] of Label); end

  def self.new(pull : JSON::PullParser)
    new.tap do |labels|
      pull.read_array { labels << Label.new(pull) }
    end
  end

  def has_label(nm : String) : Bool
    @labels.any? { |lbl| lbl.name == nm }
  end
end

# Сведения об издании релиза.
# Релиз характеризуется годов выпуска и может распространяться в нескольких странах
# под разными лейбами.
class Issue
  include JSON::Serializable

  property countries = [] of String
  property labels = Labels.new
  property notes = Notes.new
  property year = 0

  def initialize
    @labels = Labels.new
    @countries = [] of String
    @year = 0
    @notes = Notes.new
  end

  # Compare a ReleaseLabel object with other one.
  def compare(other : self) : Float64
    @labels.each do |lbl|
      lbl.catnos.each do |catno|
        return 1.0 if other.has_catno(catno)
      end
    end
    @labels.each { |lbl| return 0.99 if other.has_label(lbl.name) }
    0.0
  end

  # Добавление лейбла с указанным именем.
  #
  # В случае наличия метки с таким именем проводится обновление целевых полей исходным `Label`.
  def add_label(l : Label)
    lbl = label(l.name)
    if lbl
      lbl.merge_with(l)
    else
      @labels << l
    end
  end

  # Helper-метод для добавленія в інформацію о публікаціі Label і определенного
  # номера каталога
  def add_label_catno(lbl_name : String, catno : String)
    lbl = Label.new(lbl_name)
    lbl.catnos << catno
    add_label(lbl)
  end

  def catnos : Array(CatNo)
    @labels.flat_map(&.catnos.to_a)
  end

  # Проверка наличия номер каталога в хранимых данных.
  def has_catno(catno : String) : Bool
    @labels.any?(&.catnos.includes?(catno))
  end

  # Проверка наличия лейбла в выпуске.
  def has_label(name : String) : Bool
    @labels.has_label(name)
  end

  def empty? : Bool
    @labels.empty? && @countries.empty? && @year == 0 && @notes.empty?
  end

  def label(name : String) : Label | Nil
    @labels.find { |lbl| lbl.name == name }
  end
end

# Перечень изданий релиза.
class Issues
  include JSON::Serializable
  include Enumerable(Issue)
  delegate :<<, :[]=, :each, :size, :to_json, to: @pubs

  def initialize
    # [0] - исходное издание, [1] - данное издание
    @pubs = Array(Issue).new(2) { Issue.new }
  end

  def self.new(pull : JSON::PullParser)
    Issues.new.tap do |issues|
      i = 0
      pull.read_array do
        if i < issues.size
          issues[i] = Issue.new(pull)
        else
          issues << Issue.new(pull)
        end
        i += 1
      end
    end
  end

  # Сведения об актуальном издании альбома.
  def actual : Issue
    @pubs[1]
  end

  def actual=(p : Issue)
    @pubs[1] = p
  end

  # Сведения о предыдущем или исходном издании альбома.
  def ancestor : Issue
    @pubs[0]
  end

  def ancestor(p : Issue)
    @pubs[0] = p
  end
end
