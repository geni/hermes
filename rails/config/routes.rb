Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  mount ActionCable.server => "/websocket"

  # Defines the root path route ("/")
  root "hermes#index"

  get   '/dashboard' => 'hermes#dashboard'
  post  '/*topic'    => 'hermes#publish'
  put   '/*topic'    => 'hermes#publish'
end
