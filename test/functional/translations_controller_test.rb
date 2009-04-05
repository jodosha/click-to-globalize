require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class TranslationsControllerTest < ActionController::TestCase
  test "should have translation mode enabled by default" do
    assert @controller.globalize?
  end

  test "should clear globalize cache" do
    flunk
  end
end

class AnApplicationController < ApplicationController
  before_filter :set_locale

  def index
    render :file => File.expand_path(File.dirname(__FILE__) + "/../fixtures/index.html.erb")
  end

  private
    def set_locale
      I18n.locale = params[:locale]
    end
end
module AnApplicationHelper; end

class AnApplicationControllerTest < ActionController::TestCase
  setup :load_translations

  test "should have translation mode enabled by default" do
    assert @controller.globalize?
  end

  test "should return translated contents" do
    get :index, params
    assert_response :success

    expected = { "hello_world" => "Hello, World!" }
    assert translations.any?
    assert_equal expected, translations
  end

  test "should always render the action" do
    @controller.stubs(:globalize?).returns false

    get :index, params
    assert_response :success

    expected = { "hello_world" => "Hello, World!" }
    assert translations.any?
    assert_equal expected, translations
  end

  private
    def load_translations
      I18n.backend = I18n::Backend::Simple.new
      I18n.backend.store_translations :en, { :hello_world => "Hello, World!" }
    end

    def params(options = {})
      { :locale => "en" }.merge!(options)
    end

    def translations
      @request.session[:__globalize_translations]
    end
end
