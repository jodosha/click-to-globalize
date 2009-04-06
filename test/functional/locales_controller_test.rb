require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class LocalesControllerTest < ActionController::TestCase
  test "routing" do
    assert_routing({ :method => :put, :path => "/locales/en/change" },
      :controller => "locales", :action => "change", :id => "en" )
  end

  test "should change locale" do
    put :change, :id => "it"
    assert_redirected_to "/"
    assert_equal "it", I18n.locale
  end
end