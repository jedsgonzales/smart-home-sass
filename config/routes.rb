Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  # devise_for :users

  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  devise_scope :user do
    post "/graphql", to: "graphql#execute"
  end


  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
