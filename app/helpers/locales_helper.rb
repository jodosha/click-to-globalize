module LocalesHelper
  # Return all available locales from I18n, except <tt>:root</tt>.
  def locales
    I18n.available_locales - [ :root ]
  end

  # Creates the HTML markup for the languages picker menu.
  #
  # Example:
  # I18n.available_locales # => [:root, :en, :it]
  # I18n.locale            # => :en
  #
  #   <ul>
  #     <li><a href="/locales/en/change" title="* en">* en</a></li> |
  #     <li><a href="/locales/it/change" title="it">it</a></li>
  #   </ul>
  def locales_menu
    returning html = "" do
      html << content_tag(:ul) do
        locales.map do |locale|
          title = locale == I18n.locale ? "* #{h(locale)}" : h(locale)
          content_tag(:li) do
            link_to title, change_locale_path(locale), :title => title, :method => :put
          end
        end * " | "
      end
    end
  end
end
