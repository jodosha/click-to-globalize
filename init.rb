require 'click_to_globalize'

ActionController::Base.class_eval do
  include Click::Controller
  include Click::Observer::Controller
end

ActionView::Base.class_eval do
  include Click::Observer::View
end
