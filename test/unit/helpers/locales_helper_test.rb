require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class LocalesHelperTest < ActionView::TestCase
  test "locales" do
    assert_equal expected_locales, locales
  end
  
  test "locales_menu" do
    expected = %(<ul><li><a href=\"/locales/en/change\" title=\"en\" onclick=\"var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'put'); f.appendChild(m);f.submit();return false;\">en</a></li></ul>)
    assert_dom_equal expected, locales_menu
  end

  private
    def expected_locales
      I18n.available_locales - [ :root ]
    end
end
