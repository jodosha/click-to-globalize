require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class LocaleObserverTest < ActiveSupport::TestCase
  include Click::Observer
  setup :load_translations

  test "should have empty translations when instantiated" do
    assert LocaleObserver.new.translations.empty?
  end

  test "should update translations" do
    expected = { "hello_world" => "Hello, World!" }
  
    locale_observer.update "hello_world", "Hello, World!"
    assert_equal expected, locale_observer.translations
  
    expected.merge!({ "hello_world" => "Ciao, Mondo!" })
    locale_observer.update "hello_world", "Ciao, Mondo!"
    assert_equal expected, locale_observer.translations
  end

  test "should not raise exception if try to update with nil translations" do
    assert_nothing_raised Exception do
      locale_observer.update nil, nil
      assert_equal({nil => nil}, locale_observer.translations)
    end
  end
end
