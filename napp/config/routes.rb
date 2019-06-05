Rails.application.routes.draw do
  resources :products
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #get 'get_asin' => 'application#get_asin'
  get 'get_asin' => 'application#scrape_amazon'
  root 'application#get_asin'
  #root 'application#scrape_amazon'
  #post 'scrape_amazon' => 'application#scrape_amazon'
end
