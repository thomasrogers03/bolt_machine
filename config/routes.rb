Rails.application.routes.draw do
  root 'jobs#index'
  resources :jobs, only: [:index, :new, :edit, :create, :update]
  get 'jobs/:id/json' => 'jobs#json_graph'
  resources :node_definitions, only: [:index, :new, :edit, :create, :update]
end
