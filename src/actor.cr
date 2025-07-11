require "json"
require "levenshtein"

require "./id"
require "./json"

alias Name = String
alias Role = String

class ActorIDs
  include Enumerable({String, IDs})
  delegate :[], :[]=, :each, :size, :empty?, :has_key?, :fetch, :to_json, to: @ids

  def initialize(@ids = {} of String => IDs)
  end

  def self.new(pull : JSON::PullParser)
    new.tap do |ids|
      pull.read_object do |k|
        ids[k] = IDs.new(pull)
      end
    end
  end
end

class Roles
  include JSON::Serializable
  include Enumerable({Name, Set(Role)})
  delegate :[], :[]=, :each, :size, :empty?, :has_key?, :keys, :to_json, to: @roles

  PERFORMER = "performer"

  def initialize(@roles = Hash(String, Set(Role)).new { |hash, k| hash[k] = Set(Role).new })
  end

  def self.new(pull : JSON::PullParser)
    new.tap do |roles|
      pull.read_object do |k|
        pull.read_array do
          roles[k] << Role.new(pull)
        end
      end
    end
  end

  # Добавление роли (без перезаписи)
  def add(name : Name, role : String = PERFORMER)
    @roles[name] << role
  end

  # Получение всех ролей по ключу (или пустой массив)
  def roles(key : Name) : Array(Role)
    @roles.fetch(key, [] of String)
  end

  # Удаление всех ролей по ключу
  def clear(key : Name)
    @roles.delete(key)
  end

  def compare(other : self) : Float64
    return 0.0 if empty? || other.empty?
    ret = 0.0
    @roles.keys.each do |name|
      other.keys.each do |other_name|
        res = 1.0 - Levenshtein.distance(name, other_name) / 100
        ret = Math.max(res, ret)
      end
    end
    ret
  end

  def delete(actor : Name, role : Role)
    if @roles.has_key?(actor)
      @roles[actor].delete(role)
      if @roles[actor].empty?
        @roles.delete(actor)
      end
    end
  end

  def performers : Roles
    Roles.new(@roles.select { |_, roles| roles.includes?(PERFORMER) })
  end
end
