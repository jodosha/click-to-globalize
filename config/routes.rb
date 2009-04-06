ActionController::Routing::Routes.draw do |map|
  map.resources :translations, :only => [ :index ], :member => { :save   => :post }
  map.resources :locales,      :only => [ ],        :member => { :change => :put  }
end
