require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class ClickToGlobalizeHelperTest < ActionView::TestCase  
  test "authenticity_token with protection from forgery active" do
    stubs(:protect_against_forgery?).returns true
    assert_equal form_authenticity_token, authenticity_token
  end

  test "authenticity_token with protection from forgery inactive" do
    assert_equal "", authenticity_token
  end
end