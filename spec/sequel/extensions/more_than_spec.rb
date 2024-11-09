# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Sequel::MoreThan do
  describe "#more_than?" do
    context "with `number_of_rows` below 0" do
      it "returns true for an empty dataset" do
        more_than_minus_one = DB[:table].more_than?(-1)

        expect(more_than_minus_one).to be(true)
      end

      it "returns true for a dataset with one row" do
        DB[:table].insert(column: 1)

        more_than_minus_one = DB[:table].more_than?(-1)

        expect(more_than_minus_one).to be(true)
      end

      it "returns true for a dataset with multiple rows" do
        DB[:table].insert(column: 1)
        DB[:table].insert(column: 2)

        more_than_minus_one = DB[:table].more_than?(-1)

        expect(more_than_minus_one).to be(true)
      end

      it "does not hit the database" do
        db = Sequel.mock.extension(:more_than)

        db[:table].more_than?(-1)

        expect(db.sqls).to be_empty
      end
    end

    context "with `number_of_rows` = 0" do
      it "returns false for an empty dataset" do
        more_than_zero = DB[:table].more_than?(0)

        expect(more_than_zero).to be(false)
      end

      it "returns true for a dataset with one row" do
        DB[:table].insert(column: 1)

        more_than_zero = DB[:table].more_than?(0)

        expect(more_than_zero).to be(true)
      end

      it "returns true for a dataset with multiple rows" do
        DB[:table].insert(column: 1)
        DB[:table].insert(column: 2)

        more_than_zero = DB[:table].more_than?(0)

        expect(more_than_zero).to be(true)
      end

      it "generates correct SQL" do
        db = Sequel.mock.extension(:more_than)

        db[:table].more_than?(0)

        expect(db.sqls).to contain_exactly(
          "SELECT 1 AS one FROM table LIMIT 1"
        )
      end
    end

    context "with `number_of_rows` = 1" do
      it "returns false for an empty dataset" do
        more_than_one = DB[:table].more_than?(1)

        expect(more_than_one).to be(false)
      end

      it "returns false for a dataset with one row" do
        DB[:table].insert(column: 1)

        more_than_one = DB[:table].more_than?(1)

        expect(more_than_one).to be(false)
      end

      it "returns true for a dataset with multiple rows" do
        DB[:table].insert(column: 1)
        DB[:table].insert(column: 2)

        more_than_one = DB[:table].more_than?(1)

        expect(more_than_one).to be(true)
      end

      it "generates correct SQL" do
        db = Sequel.mock.extension(:more_than)

        db[:table].more_than?(1)

        expect(db.sqls).to contain_exactly(
          "SELECT (EXISTS (SELECT * FROM table LIMIT 1 OFFSET 1)) AS v LIMIT 1"
        )
      end
    end

    context "with `number_of_rows` = 2" do
      it "returns false for an empty dataset" do
        more_than_two = DB[:table].more_than?(2)

        expect(more_than_two).to be(false)
      end

      it "returns false for a dataset with one row" do
        DB[:table].insert(column: 1)

        more_than_two = DB[:table].more_than?(2)

        expect(more_than_two).to be(false)
      end

      it "returns false for a dataset with two rows" do
        DB[:table].insert(column: 1)
        DB[:table].insert(column: 2)

        more_than_two = DB[:table].more_than?(2)

        expect(more_than_two).to be(false)
      end

      it "returns true for a dataset with at least three rows" do
        DB[:table].insert(column: 1)
        DB[:table].insert(column: 2)
        DB[:table].insert(column: 3)

        more_than_two = DB[:table].more_than?(2)

        expect(more_than_two).to be(true)
      end

      it "generates correct SQL" do
        db = Sequel.mock.extension(:more_than)

        db[:table].more_than?(2)

        expect(db.sqls).to contain_exactly(
          "SELECT (EXISTS (SELECT * FROM table LIMIT 1 OFFSET 2)) AS v LIMIT 1"
        )
      end
    end

    context "with an invalid argument" do
      it "raises ArgumentError" do
        ["foo", nil, 3.14, false, true].each do |invalid_argument|
          expect do
            DB[:table].more_than?(invalid_argument)
          end.to raise_error(
            ArgumentError,
            "`number_of_rows` must be an Integer, got #{invalid_argument.inspect}"
          )
        end
      end
    end
  end

  describe "#fewer_than?" do
    context "with `number_of_rows` below 0" do
      it "returns false for an empty dataset" do
        fewer_than_minus_one = DB[:table].fewer_than?(-1)

        expect(fewer_than_minus_one).to be(false)
      end

      it "returns false for a dataset with one row" do
        DB[:table].insert(column: 1)

        fewer_than_minus_one = DB[:table].fewer_than?(-1)

        expect(fewer_than_minus_one).to be(false)
      end

      it "returns false for a dataset with multiple rows" do
        DB[:table].insert(column: 1)
        DB[:table].insert(column: 2)

        fewer_than_minus_one = DB[:table].fewer_than?(-1)

        expect(fewer_than_minus_one).to be(false)
      end

      it "does not hit the database" do
        db = Sequel.mock.extension(:more_than)

        db[:table].fewer_than?(-1)

        expect(db.sqls).to be_empty
      end
    end

    context "with `number_of_rows` = 0" do
      it "returns false for an empty dataset" do
        fewer_than_zero = DB[:table].fewer_than?(0)

        expect(fewer_than_zero).to be(false)
      end

      it "returns false for a dataset with one row" do
        DB[:table].insert(column: 1)

        fewer_than_zero = DB[:table].fewer_than?(0)

        expect(fewer_than_zero).to be(false)
      end

      it "returns false for a dataset with multiple rows" do
        DB[:table].insert(column: 1)
        DB[:table].insert(column: 2)

        fewer_than_zero = DB[:table].fewer_than?(0)

        expect(fewer_than_zero).to be(false)
      end

      it "does not hit the database" do
        db = Sequel.mock.extension(:more_than)

        db[:table].fewer_than?(0)

        expect(db.sqls).to be_empty
      end
    end

    context "with `number_of_rows` = 1" do
      it "returns true for an empty dataset" do
        fewer_than_one = DB[:table].fewer_than?(1)

        expect(fewer_than_one).to be(true)
      end

      it "returns false for a dataset with one row" do
        DB[:table].insert(column: 1)

        fewer_than_one = DB[:table].fewer_than?(1)

        expect(fewer_than_one).to be(false)
      end

      it "returns false for a dataset with multiple rows" do
        DB[:table].insert(column: 1)
        DB[:table].insert(column: 2)

        fewer_than_one = DB[:table].fewer_than?(1)

        expect(fewer_than_one).to be(false)
      end

      it "generates correct SQL" do
        db = Sequel.mock.extension(:more_than)

        db[:table].fewer_than?(1)

        expect(db.sqls).to contain_exactly("SELECT 1 AS one FROM table LIMIT 1")
      end
    end

    context "with `number_of_rows` = 2" do
      it "returns true for an empty dataset" do
        fewer_than_two = DB[:table].fewer_than?(2)

        expect(fewer_than_two).to be(true)
      end

      it "returns true for a dataset with one row" do
        DB[:table].insert(column: 1)

        fewer_than_two = DB[:table].fewer_than?(2)

        expect(fewer_than_two).to be(true)
      end

      it "returns false for a dataset with at least two rows" do
        DB[:table].insert(column: 1)
        DB[:table].insert(column: 2)

        fewer_than_two = DB[:table].fewer_than?(2)

        expect(fewer_than_two).to be(false)
      end

      it "generates correct SQL" do
        db = Sequel.mock.extension(:more_than)

        db[:table].fewer_than?(2)

        expect(db.sqls).to contain_exactly(
          "SELECT (EXISTS (SELECT * FROM table LIMIT 1 OFFSET 1)) AS v LIMIT 1"
        )
      end
    end

    context "with an invalid argument" do
      it "raises ArgumentError" do
        ["foo", nil, 3.14, false, true].each do |invalid_argument|
          expect do
            DB[:table].fewer_than?(invalid_argument)
          end.to raise_error(
            ArgumentError,
            "`number_of_rows` must be an Integer, got #{invalid_argument.inspect}"
          )
        end
      end
    end
  end
end
