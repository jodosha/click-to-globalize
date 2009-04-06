require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

TranslationsController.class_eval do
  before_filter do |controller|
    controller.request.session[:__translations] = { "hello_world" => "Hello, World!" }
  end
end

class TranslationsControllerTest < ActionController::TestCase
  test "should have translation mode enabled by default" do
    assert @controller.in_place_translations?
  end

  test "routing" do
    assert_routing({ :method => :get,  :path => "/translations" },
      :controller => "translations", :action => "index" )
    assert_routing({ :method => :post, :path => "/translations/save" },
      :controller => "translations", :action => "save" )
  end

  test "should return session translations" do
    get :index, {}, :format => :json
    assert_response :success
    assert_equal "{\"hello_world\": \"Hello, World!\"}", @response.body
  end

  test "should save translations" do
    xhr :post, :save, { :key => "help", :value => "Help!" }
    assert_response :success
    assert_equal "Help!", @response.body
    assert_equal "Help!", I18n.t(:help)
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
    assert @controller.in_place_translations?
  end

  test "globalize? deprecation" do
    assert_deprecated("You should use in_place_translations?"){ @controller.globalize? }
  end

  test "should return translated contents" do
    get :index, params
    assert_response :success

    expected = { "hello_world" => "Hello, World!" }
    assert translations.any?
    assert_equal expected, translations
  end

  test "should always render the action" do
    @controller.stubs(:in_place_translations?).returns false

    get :index, params
    assert_response :success

    expected = { "hello_world" => "Hello, World!" }
    assert translations.any?
    assert_equal expected, translations
  end

  private
    def params(options = {})
      { :locale => "en" }.merge!(options)
    end

    def translations
      @request.session[:__translations]
    end
end
