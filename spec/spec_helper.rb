# frozen_string_literal: true

require "sequel"
require "sequel/extensions/more_than"

DB = Sequel.connect("postgres:///sequel_more_than")

DB.drop_table?(:table)

DB.create_table(:table) do
  primary_key(:id)
  integer(:column)
end

DB.extension(:more_than)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.disable_monkey_patching!

  config.expect_with(:rspec) do |c|
    c.syntax = :expect
  end

  config.before do
    DB[:table].delete
  end
end
