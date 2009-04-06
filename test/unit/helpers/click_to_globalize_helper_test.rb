require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class ClickToGlobalizeHelperTest < ActionView::TestCase
  setup :stubs_action_view_methods

  test "authenticity_token with protection from forgery active" do
    stubs(:protect_against_forgery?).returns true
    assert_equal form_authenticity_token, authenticity_token
  end

  test "authenticity_token with protection from forgery inactive" do
    assert_equal "", authenticity_token
  end

  test "click_to_globalize" do
    expected = %(<script type=\"text/javascript\" src=\"/javascripts/click_to_globalize.js\"></script>\n<link href=\"/stylesheets/click_to_globalize.css\" rel=\"stylesheet\" type=\"text/css\" media=\"all\" />\n<div id=\"click_to_globalize\"><ul><li><a href=\"/locales/en/change\" title=\"en\" onclick=\"var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'put'); f.appendChild(m);f.submit();return false;\">en</a></li></ul></div>\n<script language=\"javascript\" type=\"text/javascript\" charset=\"utf-8\">\n// <![CDATA[\n  var ctg = new ClickToGlobalize('hack', 'hackhack');\n// ]]>\n</script>\n)
    assert_dom_equal expected, click_to_globalize
  end

  private
    def stubs_action_view_methods
      html = %(<ul><li><a href=\"/locales/en/change\" title=\"en\" onclick=\"var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'put'); f.appendChild(m);f.submit();return false;\">en</a></li></ul>)
      ActionView::Base.any_instance.stubs(:locales_menu).returns html
      ActionView::Base.any_instance.stubs(:authenticity_token).returns "hack"
      ActionView::Base.any_instance.stubs(:request_forgery_protection_token).returns "hackhack"
    end
end