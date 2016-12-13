Rails.application.routes.draw do
  root 'jobs#index'
  resources :jobs, only: [:index, :new, :edit, :create, :update]
  get 'jobs/:id/script/json' => 'jobs#script_json', as: 'job_script_json'
  post 'jobs/:id/execute' => 'jobs#execute', as: 'execute_job'
  resources :node_definitions, only: [:index, :new, :edit, :create, :update]
end
