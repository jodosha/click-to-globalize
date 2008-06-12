Test::Unit::TestCase.fixture_path = File.expand_path(File.dirname(__FILE__)) + "/fixtures/"
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)

Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, %w(countries languages translations).collect{|table_name| "globalize_#{table_name}"})

class Test::Unit::TestCase
  def uses_config_file(config_file, &block)
    old_config_file = Locale.config_file
    Locale.config_file = old_config_file.gsub(/\w+\.\w+$/, config_file)
    Locale.configuration = false
    yield
    Locale.configuration = false
    Locale.config_file = old_config_file
  end
end

module Globalize #:nodoc:
  class Locale #:nodoc:
    cattr_writer :formatting, :configuration
  end
  
  module Helpers #:nodoc:
    def self.click_partial #:nodoc:
      @@click_partial
    end
  end
end
