# ClickToGlobalize
require 'yaml'

module Globalize # :nodoc:
  class NoConfiguredLocalesError < StandardError #:nodoc:
    def to_s
      "No configured locales in #{Locale.config_file}"
    end
  end

  class NoBaseLanguageError < StandardError #:nodoc:
    def to_s
      "No configured base language."
    end
  end

  class Locale # :nodoc:
    # It's the file used to configure the locales in your app.
    # Please look at README for more information about the configuration.
    @@config_file = RAILS_ROOT + '/config/click.yml'
    cattr_accessor :config_file
    
    # Contains an hash of locales configured in config_file
    @@all = nil
    cattr_writer :all
    
    # It's the formatting style (Textile or Markdown) configured in config_file
    @@formatting = nil
    
    class << self
      alias_method :__translate, :translate
      def translate(key, default = nil, arg = nil, namespace = nil) # :nodoc:
        result = __translate(key, default, arg, namespace)
        notify_observers(key, result)
        result
      end
      
      # Returns the active <tt>Locale</tt> or create a new one, checking the choosen base language.
      # To easily plug-in this code I need always a ready Locale.
      def active
        @@active ||= Locale.set(@@base_language_code.locale)
      end
      
      # Check if the the class has a current active <tt>Locale</tt>, calling the homonymous method.
      # To easily plug-in this code I need always a ready <tt>Locale</tt>.
      def active?
        !active.nil?
      end
      
      def all #:nodoc:
        @@all ||= load_locales
      end
      
      # Hash representation of config_file.
      def configuration
        @@configuration ||= YAML::load_file(config_file)
      end
      
      # Load all the locales in config_file.
      def load_locales
        raise NoConfiguredLocalesError unless configuration
        configuration['locales'].symbolize_keys!
      end
      
      # Load the base language if configured in config_file.
      def load_configured_base_language
        language_key = configuration['default']
        self.set_base_language(all[language_key]) unless language_key.nil?
      end
      
      def notify_observers(key, result) # :nodoc:
        observers.each { |observer| observer.update(key, result) }
      end
      
      def add_observer(observer) # :nodoc:
        observers << observer
      end
      
      def remove_observer(observer) # :nodoc:
        observers.delete(observer)
      end
      
      def observers # :nodoc:
        @observers ||= Set.new
      end
            
      # Return the current formatting style defined in config_file.
      #
      # The options available are:
      #   * textile (RedCloth gem)
      #   * markdown (BlueCloth gem)
      def formatting
        @@formatting ||= case configuration['formatting'].to_sym
          when :textile  then textile?  ? :textile  : nil
          when :markdown then markdown? ? :markdown : nil
          else           raise ArgumentError
        end
      end

      # Returns the method for the current formatting style.
      #
      # The available methods are:
      #   * textilize_without_paragraph (textile)
      #   * markdown (markdown)
      def formatting_method
        case @@formatting
          when :textile  then :textilize_without_paragraph
          when :markdown then :markdown
        end
      end

      # Checks if the RedCloth gem is installed and already required.
      def textile?
        @@textile ||= Object.const_defined?(:RedCloth)
      end
      
      # Checks if the BlueCloth gem is installed and already required.
      def markdown?
        @@markdown ||= Object.const_defined?(:BlueCloth)
      end
    end
  end 

  # Implements the Observer Pattern, when <tt>Locale#translate</tt> is called,
  # it notify <tt>LocaleObserver</tt>, passing the translation key and the result for
  # the current locale.
  class LocaleObserver
    attr_reader :translations
    
    def initialize # :nodoc:
      @translations = {}
    end
    
    def update(key, result) # :nodoc:
      @translations = @translations.merge({key, result})
    end
  end
  
  module Helpers # :nodoc:
    @@click_partial = 'shared/_click_to_globalize'
    
    # Render +app/views/shared/_click_to_globalize.html.erb+.
    def click_to_globalize
      # Note: controller.class.globalize? is deprecated.
      return unless controller.globalize? && controller.class.globalize?
      render @@click_partial
    end
    
    # Get form_authenticity_token if the application is protected from forgery.
    # See ActionController::RequestForgeryProtection for details.
    def authenticity_token
      protect_against_forgery? ? form_authenticity_token : ''
    end
    
    # Returns the languages defined in Locale#config_file
    def languages
      Locale.all
    end
    
    # Creates the HTML markup for the languages picker menu.
    #
    # Example:
    #   config/click.yml
    #     locales:
    #       english: en-US
    #       italian: it-IT
    #
    #   <ul>
    #     <li><a href="/locales/set/en-US" title="* English [en-US]">* English</a></li> |
    #     <li><a href="/locales/set/it-IT" title="Italian [it-IT]">Italian</a></li>
    #   </ul>
    def languages_menu
      returning result = '<ul>' do
        result << languages.map do |language, locale|
          language = language.to_s.titleize
          language = "* #{language}" if locale == Locale.active.code
          "<li>#{link_to language, {:controller => 'locales', :action => 'set', :id => locale}, {:title => "#{language} [#{locale}]"}}</li>"
        end * ' | '
      end
      result << '</ul>'
    end
  end
  
  module Controller # :nodoc:
    module InstanceMethods # :nodoc:
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
      
      private
      # It's used as around_filter method, to add a <tt>LocaleObserver</tt> while the
      # request is processed.
      # <tt>LocaleObserver</tt> catches all translations and pass them to the session.
      def observe_locale
        locale_observer = LocaleObserver.new
        Globalize::Locale.add_observer(locale_observer)
        yield
        Globalize::Locale.remove_observer(locale_observer)
        session[:__globalize_translations] = if Locale.formatting
                                               locale_observer.translations.each{|key, translation| locale_observer.translations[key] = strip_tags(self.send(Locale.formatting_method, translation)) }
                                             else
                                               locale_observer.translations
                                             end
      end
    end
    
    module SingletonMethods      
      # Checks if the application is in globalization mode.
      #
      # Override this method in your controllers for custom conditions.
      #
      # Example:
      #
      #   def self.globalize?
      #     current_user.admin?
      #   end
      #
      # Note: this method is deprecated in favor of globalize?.
      def globalize?
        true
      end
    end
  end
end

ActionView::Base.class_eval do
  include Globalize::Helpers
end

ActionController::Base.class_eval do # :nodoc:
  extend Globalize::Controller::SingletonMethods
  include Globalize::Controller::InstanceMethods
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper
  # Note: self.globalize? is deprecated.
  around_filter :observe_locale, :except => { :controller => :locales }, :if => globalize? && self.globalize?
end