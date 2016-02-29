require_relative 'associatable'
require_relative 'searchable'
require 'active_support/inflector'
require_relative 'db_connection'


class SQLObject
  extend Searchable
  extend Associatable

  def self.columns

      @columns ||= DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      Limit
        0

      SQL
     @columns.flatten!
     @columns.map do |name|
       name.to_sym
     end

  end

  def self.finalize!
    self.columns.each do |column|

      define_method(column) do
        self.attributes[column]
      end

      define_method("#{column}=") do |value|
        self.attributes[column] = value
      end

    end

  end


  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.to_s.downcase.pluralize
  end

  def self.all
    results = []
    @all = DBConnection.execute2(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    SQL
    @all.shift

    self.parse_all(@all)

  end

  def self.parse_all(results)
    results.map do |hash|
      self.new(hash)
    end
  end

  def self.find(id)
    result = DBConnection.execute2(<<-SQL, id)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      id = ?

    SQL

    result.shift
    self.parse_all(result).first
  end

  def initialize(params = {})
    params.each do |key, val|
      key = key.to_sym
      if self.class.columns.include?(key)
        self.send("#{key}=", val)
      else
        raise "unknown attribute '#{key}'"
      end

    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    values = []
    self.attributes.each do |_,value|
      values << value
    end
    values
  end

  def insert
    col_names = self.class.columns[1..-1].join(", ")
    values = attribute_values
    question_marks = ("?," * values.size)
    question_marks = question_marks[0..-2]
    DBConnection.execute2(<<-SQL, *values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

     self.id = DBConnection.last_insert_row_id
  end

  def update
    columns = self.class.columns
    columns.map! do |col|
      col = "#{col} = ?"
    end
    columns = columns.join(",")

  DBConnection.execute2(<<-SQL, attribute_values)
   UPDATE
    #{self.class.table_name}
   SET
    #{columns}
   WHERE
    id = #{self.id}
  SQL

  end

  def save
    if self.id.nil?
      insert
    else
      update
    end
  end
end
