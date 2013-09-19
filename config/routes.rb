Portfolio::Application.routes.draw do
  get "about/about"

  resources :projects, only: [:index, :show]

  get "/about", to: 'about#about'

  get "/chess", to: "chess#new"
  get "/chess/(:white_player/:black_player/:rule_book)", to: "chess#game"

  root :to => "projects#index"

end
