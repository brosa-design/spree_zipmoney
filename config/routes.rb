Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  resources :zipmoney, only: [] do
    collection do
      post :webhook
    end

    member do
      get :success
      get :error
      get :cancel
      get :refer
      get :decline
    end
  end
end
