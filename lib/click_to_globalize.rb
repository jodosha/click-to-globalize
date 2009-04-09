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
            session[:__translations] = locale_observer.translations.stringify_keys
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
      recipient.class_eval do
        helper_method :in_place_translations?
        helper :click_to_globalize, :locales # HACK they should be loaded by default by helper :all
      end
    end

    module InstanceMethods
      include ActiveSupport::Deprecation

      # This is the <b>on/off</b> switch for the Click to Globalize features.
      # Override this method in your controllers for custom conditions.
      #
      # Example:
      #
      #   def in_place_translations?
      #     current_user.admin?
      #   end
      def in_place_translations?
        true
      end

      # This is the <b>on/off</b> switch for the Click to Globalize features.
      # Override this method in your controllers for custom conditions.
      #
      # NOTICE: this method has been deprecated in favor of <tt>in_place_translations?</tt>
      #
      # Example:
      #
      #   def globalize?
      #     current_user.admin?
      #   end
      def globalize?
        ::ActiveSupport::Deprecation.warn("You should use in_place_translations?", caller)
        true
      end
    end
  end
end
