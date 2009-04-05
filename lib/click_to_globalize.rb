# ClickToGlobalize

module Click
  module Observer
    module Controller
      def self.included(recipient)
        recipient.send :include, InstanceMethods
        # TODO avoid chain, use super instead
        recipient.class_eval do
          alias_method_chain :render, :observe
        end
      end

      module InstanceMethods
        protected
          def render_with_observe(options = nil, extra_options = {}, &block)        
            locale_observer = Click::Observer::LocaleObserver.new
            @template.add_observer locale_observer
            render_without_observe(options, extra_options, &block)
            @template.remove_observer locale_observer
            session[:__globalize_translations] = locale_observer.translations.stringify_keys
          end
      end
    end

    module View
      def self.included(recipient)
        recipient.send :include, InstanceMethods
        # TODO avoid chain, use super instead
        recipient.class_eval do
          alias_method_chain :translate, :observe
        end
      end

      module InstanceMethods
        def translate_with_observe(key, options = {})
          returning result = translate_without_observe(key, options) do
            notify_observers key, result
          end
        end
        alias_method :t, :translate_with_observe

        def notify_observers(key, result) #:nodoc:
          observers.each { |observer| observer.update(key, result) }
        end

        def add_observer(observer) #:nodoc:
          observers << observer
        end

        def remove_observer(observer) #:nodoc:
          observers.delete(observer)
        end

        def observers #:nodoc:
          @observers ||= Set.new
        end
      end
    end

    # Implements the Observer Pattern, when <tt>I18n#translate</tt> is called,
    # it notify <tt>LocaleObserver</tt>, passing the translation key and the result for
    # the current locale.
    class LocaleObserver
      attr_reader :translations

      def initialize #:nodoc:
        @translations = {}
      end

      def update(key, result) #:nodoc:
        @translations = @translations.merge({key, result})
      end
    end
  end

  module Controller
    def self.included(recipient)
      recipient.send :include, InstanceMethods
    end

    module InstanceMethods
      # This is the <b>on/off</b> switch for the Click to Globalize features.
      # Override this method in your controllers for custom conditions.
      #
      # Example:
      #
      #   def globalize?
      #     current_user.admin?
      #   end
      def globalize?
        true
      end
    end
  end

  module Helper
    @@click_partial = 'shared/_click_to_globalize'

    # Render +app/views/shared/_click_to_globalize.html.erb+.
    def click_to_globalize
      render @@click_partial if controller.globalize?
    end

    # Get form_authenticity_token if the application is protected from forgery.
    # See ActionController::RequestForgeryProtection for details.
    def authenticity_token
      protect_against_forgery? ? form_authenticity_token : ''
    end

    def locales
      I18n.available_locales
    end

    # Creates the HTML markup for the languages picker menu.
    #
    # Example:
    # I18n.available_locales # => [:en, :it]
    # I18n.locale            # => :en
    #
    #   <ul>
    #     <li><a href="/locales/set/en" title="* en">* en</a></li> |
    #     <li><a href="/locales/set/it" title="it">it</a></li>
    #   </ul>
    def languages_menu
      returning result = '<ul>' do
        result << locales.map do |locale|
          locale = "* #{locale}" if locale == I18n.locale
          "<li>#{link_to locale, {:controller => 'locales', :action => 'set', :id => locale}, {:title => "#{language} [#{locale}]"}}</li>"
        end * ' | '
      end
      result << '</ul>'
    end
  end
end
