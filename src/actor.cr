require "json"

require "./id"
require "./utils"

alias ActorIDs = Hash(String, IDs)
alias Name = String
alias Role = String

PERFORMER = "performer"

class Roles
  include JSON::Serializable
  include Enumerable({Name, Array(Role)})
  getter storage : Hash(Name, Array(Role))

  def initialize(@storage : Hash(String, Array(Role)) = Hash(String, Array(Role)).new { |hash, k| hash[k] = Array(Role).new })
  end

  delegate :[], :[]=, :each, :size, :empty?, :has_key?, to: @storage

  # Добавление роли (без перезаписи)
  def add_role(name : Name, role : String = PERFORMER)
    @storage[name] << role
  end

  # Получение всех ролей по ключу (или пустой массив)
  def get_roles(key : Name) : Array(Role)
    @storage.fetch(key, [] of String)
  end

  # Удаление всех ролей по ключу
  def clear_roles(key : Name)
    @storage.delete(key)
  end

  def compare(other : self) : Float64
    return 0.0 if empty? || other.empty?
    ret = 0.0
    @storage.keys.each do |name|
      other.storage.keys.each do |other_name|
        res = 1.0 - levenshtein_distance(name, other_name) / 100
        ret = Math.max(res, ret)
      end
    end
    ret
  end

  def del_role(actor : Name, role : Role)
    if @storage.has_key?(actor)
      @storage[actor].delete(role)
      if @storage[actor].empty?
        @storage.delete(actor)
      end
    end
  end

  def performers : Roles
    Roles.new(@storage.select { |_, roles| roles.includes?(PERFORMER) })
  end
end
