require "json"

require "../id"
require "../note"

alias LabelName = String
alias CatNo = String

class Label
  include JSON::Serializable
  property catnos
  getter name : String, catnos : Set(CatNo), ids : IDs, notes : Notes

  def initialize(@name : String = "")
    @catnos = Set(CatNo).new
    @ids = IDs.new
    @notes = Notes.new
  end

  def merge_with(other : self)
    other.catnos.each { |catno| @catnos << catno }
    other.ids.each { |k, v| @ids[k] = v }
    other.notes.each { |note| @notes << note }
  end
end

class Labels
  include JSON::Serializable
  include Enumerable(Label)
  delegate :[], :<<, :each, :size, to: @lbs

  def initialize
    @lbs = Array(Label).new
  end

  def has_label(nm : String) : Bool
    @lbs.any? { |lbl| lbl.name == nm }
  end
end

# Сведения об издании релиза.
# Релиз характеризуется годов выпуска и может распространяться в нескольких странах
# под разными лейбами.
class Publishing
  include JSON::Serializable
  property countries, labels, notes, year

  def initialize
    @labels = Labels.new
    @countries = Array(String).new
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

class Publishings
  include JSON::Serializable
  include Enumerable(Publishing)
  delegate :each, :size, to: @pubs

  def initialize
    @pubs = Array(Publishing).new
  end
end
