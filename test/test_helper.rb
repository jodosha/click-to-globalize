require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'active_support/test_case'
require 'action_view/test_case'

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

class ActionView::TestCase
  private
    # HACK this is a placehoder, dunno why it isn't included by default
    def protect_against_forgery?
      false
    end

    # HACK this is a placehoder, dunno why it isn't included by default
    def form_authenticity_token
      "hack"
    end
end
