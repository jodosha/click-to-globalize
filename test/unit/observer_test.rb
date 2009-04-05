require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class FakeActionView
  def translate(key, options = {})
    I18n.translate key, options
  end

  include Click::Observer::View
end

class ObserverTest < ActiveSupport::TestCase
  setup :load_translations

  test "should add observers" do
    template.add_observer locale_observer
    assert template.observers.any?

    template.add_observer locale_observer #re-add
    assert template.observers.any?
    
    template.add_observer locale_observer.dup
    assert_equal 2, template.observers.size    
  end

  test "should remove observers" do
    template.add_observer locale_observer
    assert template.observers.any?

    template.remove_observer locale_observer
    assert template.observers.empty?
  end

  test "should notify observers" do
    template.add_observer locale_observer
    template.notify_observers "hello_world", "Hello, World!"
    assert_equal({"hello_world" => "Hello, World!"}, locale_observer.translations)
  end

  test "should observe translate" do
    template.add_observer locale_observer
    template.translate "hello_world"
    assert_equal({"hello_world" => "Hello, World!"}, locale_observer.translations)
  end

  private
    def template
      @template ||= FakeActionView.new
    end
end
