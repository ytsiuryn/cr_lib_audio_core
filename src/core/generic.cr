class FrequencyCounter(K)
  include Enumerable({K, Int32})
  delegate :each, to: @storage

  def initialize(@storage = {} of K => Int32); end

  # Общая версия для Array/Set (возвращает массив ключей)
  def with_frequency(freq : Int32) : Array(K)
    @storage.compact_map { |k, count| k if count == freq }
  end

  # Специальная версия для Hash (возвращает новый Hash)
  def with_frequency_hash(freq : Int32) : Hash(K, V) forall V
    result = Hash(K, V).new
    @storage.each do |(k, v), count|
      result[k] = v if count == freq
    end
    result
  end

  # Добавление элементов в счётчик
  def merge(elements : Enumerable(K)) : self
    elements.each { |elem| @storage[elem] = @storage.fetch(elem, 0) + 1 }
    self
  end
end
