ActionController::Routing::Routes.draw do |map|
  map.resources :translations, :only => [ :index ], :member => { :save => :post }
end
