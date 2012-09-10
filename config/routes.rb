#match 'admin/plugins/google_apps/:action', controller: 'google_apps', via: [:post, :get]

scope "/admin/plugins" do
  resources :google_apps_auth_sources, except: [:show] do
    get 'test_connection', on: :member
  end
end

match "google_apps/:id/login", to: 'google_apps#login', as: 'google_apps_login'
