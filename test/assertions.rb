class Test::Unit::TestCase
  # Assert the current action has all the labels translated for all given languages.
  #
  # Example:
  #   Available languages :english => 'en-US', :italian => 'it-IT', :spanish => 'es-ES'
  #
  #   def test_index_should_be_translated_in_all_languages
  #     get :index
  #     assert_translated # assert all languages
  #   end
  #
  #   def test_index_should_be_translated_in_some_languages
  #     get :index
  #     assert_translated :english, :italian # assert only English and Italian
  #   end
  #
  #  Note: The research will be performed on the *development* database,
  #  because the test database will never be filled with all the translations,
  #  but only with a subset.
  def assert_translated(*languages)
    languages = normalize_languages!(languages)
    languages.each do |language_name, code|
      instance_variables language_name, code
      language = Locale.new(code).language
      assert_language_available language
      assert_no_missing_translations(language.id)
    end
  end

  def assert_language_available(language, message = nil) #:nodoc:
    assert false, message || "Missing language in test environment: #{language_name} (#{code})." unless language
  end

  def assert_no_missing_translations(language_id, message = nil) #:nodoc:
    difference = expected_translations.values - find_translations(language_id)
    assert difference.empty?, message || "Missing translations for #{language_name} (#{code}): #{difference.inspect}"
  end

  private
    def normalize_languages!(languages) #:nodoc:
      if languages.flatten.empty?
        Locale.all
      else
        Locale.all.select { |language_name, code| languages.include? language_name }
      end
    end

    def instance_variables(language_name, code) #:nodoc:
      attr_reader_with_default :language_name, language_name
      attr_reader_with_default :code, code
    end

    def attr_reader_with_default(sym, default) #:nodoc:
      self.class.send :define_method, sym, Proc.new { default }
    end

    def find_translations(language_id) #:nodoc:
      ViewTranslation.find(:all, :conditions => ['language_id = ? AND tr_key IN(?)', language_id, expected_translations.keys]).map(&:text)
    end

    def expected_translations #:nodoc:
      @expected_translations ||= session[:__translations]
    end
end

class Globalize::ViewTranslation #:nodoc:
  self.connection = self.configurations['development']
end

class ApplicationController #:nodoc:
  around_filter :observe_locales_for_test
  
  private
    def observe_locales_for_test
      locale_observer = LocaleObserver.new
      Locale.add_observer(locale_observer)
      yield
      Locale.remove_observer(locale_observer)
      session[:__translations] = format_translations(locale_observer)
    end
end
