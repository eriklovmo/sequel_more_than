# frozen_string_literal: true

require "sequel"
require_relative "../more_than/version"

# The more_than extension adds the Dataset#more_than? and Dataset#fewer_than? methods,
# which can be used to efficiently determine whether a dataset contains more than or
# fewer rows than a given number.
#
#   DB[:table].more_than?(0)
#   # SELECT 1 AS one FROM table LIMIT 1
#
#   DB[:table].fewer_than?(1)
#   # SELECT 1 AS one FROM table LIMIT 1
#
#   DB[:table].more_than?(2)
#   # SELECT (EXISTS (SELECT * FROM table LIMIT 1 OFFSET 2)) AS v LIMIT 1
#
#   # DB[:table].fewer_than?(2)
#   # SELECT (EXISTS (SELECT * FROM table LIMIT 1 OFFSET 1)) AS v LIMIT 1
#
# You can load this extension into specific datasets:
#
#   ds = DB[:table].extension(:more_than)
#
# Or you can load it into all of a database's datasets:
#
#   DB.extension(:more_than)

module Sequel
  module Extensions
    module MoreThan
      def more_than?(number_of_rows)
        unless number_of_rows.is_a?(Integer)
          raise ArgumentError,
                "`number_of_rows` must be an Integer, got #{number_of_rows.inspect}"
        end

        if number_of_rows.negative?
          true
        elsif number_of_rows.zero?
          !empty?
        else
          subquery = unordered.limit(1).offset(number_of_rows)
          @db.get(subquery.exists)
        end
      end

      def fewer_than?(number_of_rows)
        unless number_of_rows.is_a?(Integer)
          raise ArgumentError,
                "`number_of_rows` must be an Integer, got #{number_of_rows.inspect}"
        end

        if number_of_rows.negative? || number_of_rows.zero?
          false
        elsif number_of_rows == 1
          empty?
        else
          !more_than?(number_of_rows - 1)
        end
      end
    end
  end

  Sequel::Dataset.register_extension(:more_than, Sequel::Extensions::MoreThan)
end
