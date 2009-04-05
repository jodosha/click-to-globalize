require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'active_support/test_case'

class ActiveSupport::TestCase
  private
    def load_translations
      I18n.backend = I18n::Backend::Simple.new
      I18n.backend.store_translations :en, { :hello_world => "Hello, World!" }
    end

    def locale_observer
      @locale_observer ||= Click::Observer::LocaleObserver.new
    end
end