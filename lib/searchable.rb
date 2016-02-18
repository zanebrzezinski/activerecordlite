require 'byebug'
require_relative 'associatable'
require_relative 'searchable'
require 'active_support/inflector'
require_relative 'db_connection'

module Searchable
  def where(params)
    whereline = params.map {|k, _| "#{k} = ?"}.join(" AND ")
    values = []
    params.map { |_, v| values << v }

    results = DBConnection.execute2(<<-SQL, values)
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      #{whereline}
    SQL
    results.shift
    parse_all(results)
  end
end
