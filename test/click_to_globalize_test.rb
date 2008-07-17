require 'test/test_helper'
require 'test/unit'
require File.dirname(__FILE__) + '/test_helper'

class ClickToGlobalizeController < ApplicationController
  around_filter :observe_locales
  def index
    Locale.set(params[:locale])
    translation = Translation.find_by_tr_key_and_language_id(params[:key], params[:language_id])
    @greet = translation.tr_key.t
    render :nothing => true, :status => 200
  end
end
module ClickToGlobalizeHelper; end

class ClickToGlobalizeTest < Test::Unit::TestCase
  ActiveRecord::Base.store_full_sti_class = false
  include ApplicationHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper

  attr_accessor :protect_against_forgery, :form_authenticity_token

  def setup
    Locale.active = nil

    Locale.config_file = File.dirname(__FILE__) + '/config/click.yml'
    Locale.load_configured_base_language

    # TODO load w/ #inject
    @hello_world  = Translation.find(1)
    @ciao_mondo   = Translation.find(2)

    @default_locale = Locale.new('en-US')
    @italian_locale = Locale.new('it-IT')

    @click_partial  = 'shared/_click_to_globalize'
    @base_language  = {:english => 'en-US'}
    @languages      = {:english => 'en-US', :italian => 'it-IT'}

    @inline = { :textile  => 'textilize_without_paragraph( @formatted_value )',
                :markdown => 'markdown( @formatted_value )',
                :other    => '@formatted_value' }

    @locales_controller = LocalesController.new

    @controller = ClickToGlobalizeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    self.protect_against_forgery = true
    self.form_authenticity_token = '123'
  end

  def teardown
    Locale.formatting = Locale.configuration['formatting'].to_sym
    Locale.observers.clear
  end

  ### LOCALE_OBSERVER

  def test_should_instantiate
    locale_observer = LocaleObserver.new
    assert_empty locale_observer.translations
  end

  def test_should_update_translations
    expected = { @hello_world.tr_key => @hello_world.text }

    locale_observer.update @hello_world.tr_key, @hello_world.text
    assert_equal expected, locale_observer.translations

    expected.merge!({ @ciao_mondo.tr_key => @ciao_mondo.text })
    locale_observer.update @ciao_mondo.tr_key, @ciao_mondo.text
    assert_equal expected, locale_observer.translations
  end

  def test_should_raise_no_exception_on_updating_nil_translations
    assert_nothing_raised Exception do
      locale_observer.update nil, nil
      assert_equal({nil => nil}, locale_observer.translations)
    end
  end

  ### LOCALE

  def test_should_return_active_locale
    assert_equal @default_locale.code, Locale.active.code
  end

  def test_should_always_return_active_locale
    Locale.active = nil
    assert_not_nil Locale.active
    assert Locale.active?
  end

  def test_should_set_active_locale
    Locale.set @italian_locale.code
    assert_equal @italian_locale.code, Locale.active.code
  end

  def test_should_load_locales_from_configuration_file
    Locale.load_locales
    assert_equal @languages, Locale.all
  end

  def test_should_raise_exception_for_missing_configured_languages
    uses_config_file 'empty.yml' do
      assert_raise(NoConfiguredLocalesError) { Locale.configuration }
    end
  end

  def test_should_load_configured_base_language
    Locale.load_configured_base_language
    assert_equal(@default_locale.code, Locale.active.code)
  end

  def test_locale_method_aliases
    assert Locale.respond_to?(:__translate)
    assert Locale.respond_to?(:translate)
  end

  def test_locale_observers_should_be_a_set
    assert_kind_of Set, Locale.observers
  end

  def test_should_add_observers
    Locale.add_observer locale_observer
    assert_any Locale.observers

    Locale.add_observer locale_observer # re-add
    assert_any Locale.observers

    Locale.add_observer locale_observer.dup
    assert_size_equal 2, Locale.observers
  end

  def test_should_remove_observers
    Locale.add_observer locale_observer
    assert_any Locale.observers

    Locale.remove_observer locale_observer
    assert_empty Locale.observers
  end

  def test_should_notify_observers
    Locale.add_observer locale_observer
    Locale.notify_observers @hello_world.tr_key, @hello_world.text

    assert_equal({@hello_world.tr_key => @hello_world.text},
      locale_observer.translations)
  end

  def test_should_observe_translate
    Locale.add_observer locale_observer
    @hello_world.tr_key.t

    assert_equal({@hello_world.tr_key => @hello_world.text},
      locale_observer.translations)
  end

  def test_should_load_formatting_from_configuration_file
    assert_equal :textile, Locale.formatting
  end

  def test_textile
    if installed? RedCloth
      assert Locale.textile?
    else
      assert_not Locale.textile?
    end
  end

  def test_markdown
    if installed? BlueCloth
      assert Locale.markdown?
    else
      assert_not Locale.markdown?
    end
  end

  ### HELPERS
  
  def test_helper_partial
    assert_equal @click_partial, Helpers.click_partial
  end

  def test_helper_authenticity_token_should_return_form_authenticity_token_when_protect_against_forgery_is_active
    assert_equal self.form_authenticity_token, authenticity_token
  end

  def test_helper_authenticity_token_should_return_empty_string_when_protect_against_forgery_is_not_active
    self.protect_against_forgery = false
    assert_empty authenticity_token
  end

  def test_helper_languages
    Locale.all = @languages
    assert_equal @languages, languages
  end

  def test_helper_languages_menu
    get :index, params # make sure ActionView request cycle is active
    expected = %(<ul><li><a href="/locales/set/en-US" title="* English [en-US]">* English</a></li> | <li><a href="/locales/set/it-IT" title="Italian [it-IT]">Italian</a></li></ul>)

    assert_equal expected, languages_menu
  end

  ### CONTROLLER

  def test_controller_globalize
    assert @controller.globalize?
  end

  def test_controller_observe_locales
    get :index, params
    assert_response :success

    expected = { @hello_world.tr_key => @hello_world.text }
    assert_any translations
    assert_equal expected, translations
  end

  def test_should_return_formatted_translations
    create_translation('hello_mars', '*Hello Mars!*')
    with_formatting :textile do
      get :index, params(:key => 'hello_mars')
      assert_response :success
      
      expected = { 'hello_mars' => %(<strong>Hello Mars!</strong>) }
      assert_equal expected, translations
    end
  end

  uses_mocha 'ClickToGlobalizeFormattingTest' do
    def test_should_return_plain_translations
      Locale.stubs(:formatting).returns nil
      create_translation('hello_moon', '*Hello Moon!*')
      with_formatting :unexistent do
        get :index, params(:key => 'hello_moon')
        assert_response :success

        expected = { 'hello_moon' => '*Hello Moon!*' }
        assert_equal expected, translations
      end
    end
  end

  ### LOCALE_CONTROLLER

  def test_check_globalize
    assert @locales_controller.globalize?
  end

  def test_clear_cache
    @locales_controller.clear_cache
    assert_empty Locale.cache
  end

  def test_inline
    with_formatting :textile do
      assert_equal @inline[:textile], @locales_controller.inline
    end

    with_formatting :markdown do
      assert_equal @inline[:markdown], @locales_controller.inline
    end
  end

  def protect_against_forgery?
    !!protect_against_forgery
  end

  private
    def locale_observer
      @locale_observer ||= LocaleObserver.new
    end

    def params(options = {})
      { :key => @hello_world.tr_key, :language_id => 1, :locale => @default_locale.code }.merge!(options)
    end
    
    def translations
      @request.session[:__globalize_translations]
    end
    
    def create_translation(key, text)
      translation = Translation.new(:tr_key => key, :text => text,
        :language_id => 1, :pluralization_index => 1) do |t|
        t.type = 'ViewTranslation'
      end
      translation.save
    end
end
