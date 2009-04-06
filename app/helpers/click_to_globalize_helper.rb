module ClickToGlobalizeHelper
  @@click_partial = File.expand_path(File.dirname(__FILE__) + "/../views/shared/_click_to_globalize.html.erb")

  # Render +app/views/shared/_click_to_globalize.html.erb+.
  def click_to_globalize
    render :file => @@click_partial if in_place_translations?
  end

  # Get form_authenticity_token if the application is protected from forgery.
  # See ActionController::RequestForgeryProtection for details.
  def authenticity_token
    protect_against_forgery? ? form_authenticity_token : ''
  end
end