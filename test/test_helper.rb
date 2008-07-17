Test::Unit::TestCase.fixture_path = File.expand_path(File.dirname(__FILE__)) + "/fixtures/"
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)

Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, %w(countries languages translations).collect{|table_name| "globalize_#{table_name}"})

class Test::Unit::TestCase
  # Scopify the block, using the given config file.
  def uses_config_file(config_file, &block)
    old_config_file = Locale.config_file
    Locale.config_file = old_config_file.gsub(/\w+\.\w+$/, config_file)
    Locale.configuration = false
    yield
    Locale.configuration = false
    Locale.config_file = old_config_file
  end

  # Scopify the block, using the given formatting style.
  def with_formatting(style, &block)
    old, Locale.formatting = Locale.formatting, style
    yield
    Locale.formatting = old
  end

  # Check if the given class is loaded.
  def installed?(klass)
    Object.const_defined? klass.name.to_sym
  end

  # Asserts the given condition is false.
  def assert_not(condition, message = nil)
    assert !condition, message
  end

  # Asserts the given collection is empty.
  def assert_empty(collection, message = nil)
    assert collection.empty?, message
  end

  # Asserts the given collection is *not* empty.
  def assert_not_empty(collection, message = nil)
    assert !collection.empty?, message
  end

  # Asserts the given collection size is equal to the given one.
  def assert_size_equal(size, collection, message = nil)
    assert_equal size, collection.size, message
  end

  # Asserts the given collection size is equal to one.
  def assert_any(collection, message = nil)
    assert collection.size == 1, message
  end
end

# Thanks to Rails Core Team
def uses_mocha(description)
  require 'rubygems'
  require 'mocha'
  yield
rescue LoadError
  $stderr.puts "Skipping #{description} tests. `gem install mocha` and try again."
end

LocalesController.class_eval do #:nodoc:
  public :clear_cache, :inline
end

ApplicationHelper.class_eval do #:nodoc:
  include Globalize::Helpers
end

module Globalize #:nodoc:
  class Locale #:nodoc:
    cattr_writer :formatting, :configuration, :active
    cattr_reader :cache
  end

  module Helpers #:nodoc:
    def self.click_partial #:nodoc:
      @@click_partial
    end
  end
end
