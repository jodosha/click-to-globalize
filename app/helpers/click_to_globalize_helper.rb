module ClickToGlobalizeHelper
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
end