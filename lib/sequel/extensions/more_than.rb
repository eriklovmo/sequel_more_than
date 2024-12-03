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
      # Returns true if more than *number_of_rows* records exist in the dataset, false otherwise
      #
      # Equivalent to a "greater than" (>) comparison
      #
      # @param number_of_rows [Integer] The number to compare against
      # @return [Boolean] Whether the dataset contains more rows than *number_of_rows*
      # @raise [ArgumentError] If `number_of_rows` is not an integer
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
          ds = @opts[:sql] ? from_self : self
          !ds
            .single_value_ds
            .unordered
            .offset(number_of_rows)
            .get(Sequel::SQL::AliasedExpression.new(1, :one))
            .nil?
        end
      end

      # Returns true if fewer than *number_of_rows* records exist in the dataset, false otherwise
      #
      # Equivalent to a "less than" (<) comparison
      #
      # @param number_of_rows [Integer] The number to compare against
      # @return [Boolean] Whether the dataset contains fewer rows than *number_of_rows*
      # @raise [ArgumentError] If `number_of_rows` is not an integer
      def fewer_than?(number_of_rows)
        unless number_of_rows.is_a?(Integer)
          raise ArgumentError,
            "`number_of_rows` must be an Integer, got #{number_of_rows.inspect}"
        end

        !more_than?(number_of_rows - 1)
      end

      # Returns true if at least *number_of_rows* records exist in the dataset, false otherwise
      #
      # Equivalent to a "greater than or equal to" (>=) comparison
      #
      # @param number_of_rows [Integer] The number to compare against
      # @return [Boolean] Whether the dataset contains at least *number_of_rows*
      # @raise [ArgumentError] If `number_of_rows` is not an integer
      def at_least?(number_of_rows)
        unless number_of_rows.is_a?(Integer)
          raise ArgumentError,
            "`number_of_rows` must be an Integer, got #{number_of_rows.inspect}"
        end

        more_than?(number_of_rows - 1)
      end

      # Returns true if at most *number_of_rows* records exist in the dataset, false otherwise
      #
      # Equivalent to a "less than or equal to" (<=) comparison
      #
      # @param number_of_rows [Integer] The number to compare against
      # @return [Boolean] Whether the dataset contains at most *number_of_rows*
      # @raise [ArgumentError] If `number_of_rows` is not an integer
      def at_most?(number_of_rows)
        !more_than?(number_of_rows)
      end
    end
  end

  Sequel::Dataset.register_extension(:more_than, Sequel::Extensions::MoreThan)
end
