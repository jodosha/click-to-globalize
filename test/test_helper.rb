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
  # HACK all this methods are placeholders, dunno why they aren't included by default
  private
    def protect_against_forgery?
      false
    end

    def form_authenticity_token
      "hack"
    end

    def render(options = nil, extra_options = {}, &block)
      ActionView::Base.new.render options, extra_options, &block
    end

    def in_place_translations?
      ApplicationController.new.in_place_translations?
    end
end
