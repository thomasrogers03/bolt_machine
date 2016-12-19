Rails.application.routes.draw do
  root 'jobs#index'
  resources :jobs, only: [:index, :new, :edit, :create, :update]
  post 'jobs/json_to_yaml' => 'jobs#json_to_yaml', as: 'json_to_yaml'
  get 'jobs/:id/script/json' => 'jobs#script_json', as: 'job_script_json'
  post 'jobs/:id/execute' => 'jobs#execute', as: 'execute_job'
  get 'node_definitions/:type/ports' => 'node_definitions#node_ports'
  resources :node_definitions, only: [:index, :new, :edit, :create, :update]
end
