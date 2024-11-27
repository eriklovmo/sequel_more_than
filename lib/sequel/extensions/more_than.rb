# frozen_string_literal: true

require "sequel"
require_relative "../more_than/version"

# The more_than extension adds the #more_than?, #fewer_than?, #at_most? and
# #at_least? methods to Dataset. These methods can be used to efficiently
# determine whether a dataset contains more than or fewer rows than a given number.

# You can load this extension into specific datasets:
#
#   ds = DB[:table].extension(:more_than)
#
# Or load it into all of a database's datasets:
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

         !more_than?(number_of_rows - 1)
      end

      def at_least?(number_of_rows)
        unless number_of_rows.is_a?(Integer)
          raise ArgumentError,
                "`number_of_rows` must be an Integer, got #{number_of_rows.inspect}"
        end

        more_than?(number_of_rows - 1)
      end

      def at_most?(number_of_rows)
        !more_than?(number_of_rows)
      end
    end
  end

  Sequel::Dataset.register_extension(:more_than, Sequel::Extensions::MoreThan)
end
