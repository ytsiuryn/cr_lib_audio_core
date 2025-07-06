# Комментарии к метаданным.
alias Notes = Set(String)

# Аггрегирующий набор комментариев с частотой их появления.
class FreqNotes
  include Enumerable({String, Int32})

  def initialize
    @storage = Hash(String, Int32).new
  end

  delegate :each, to: @storage

  def with_frequency(freq : Int32) : Array(String)
    @storage.compact_map { |k, frequency| k if frequency == freq }
  end

  def merge(notes : Notes)
    notes.each { |note| @storage[note] = @storage.fetch(note, 0) + 1 }
  end
end
