Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  mount Base::API => '/'

  mount SwaggerUiEngine::Engine, at: '/v1/docs'
end
