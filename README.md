# Sequel::MoreThan

This gem adds four convenience methods to `Sequel::Dataset`:

* `#more_than?`
* `#fewer_than?`
* `#at_most?`
* `#at_least?`

These methods allow you to efficiently determine whether a dataset contains more or fewer rows than a specified number.

Why use this gem?

* It generates efficient SQL queries to minimize database overhead.
* It provides a readable API for expressing dataset count comparisons.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add sequel_more_than

If Bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install sequel_more_than

## Usage

You can load this extension into specific datasets:

```ruby
ds = DB[:table].extension(:more_than)
``````

Or you can load it into all of a database’s datasets:

```ruby
DB.extension(:more_than)

DB[:table].more_than?(0)
# SELECT 1 AS one FROM table LIMIT 1

DB[:table].more_than?(1)
# SELECT 1 AS one FROM table LIMIT 1 OFFSET 1

DB[:table].fewer_than?(1)
# SELECT 1 AS one FROM table LIMIT 1

DB[:table].fewer_than?(5)
# SELECT 1 AS one FROM table LIMIT 1 OFFSET 4

DB[:table].at_least?(3)
# SELECT 1 AS one FROM table LIMIT 1 OFFSET 2

DB[:table].at_most?(2)
# SELECT 1 AS one FROM table LIMIT 1 OFFSET 2

```

## Caveats

The gem is tested on PostgreSQL. It may or may not work for other databases.

## License

This library is released under the MIT License.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eriklovmo/sequel_more_than.
