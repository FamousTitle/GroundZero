class AuthenticateAddon < Base

  def self.install
    run "rails generate authentication"
    run "rails db:migrate"

    routes_path = "config/routes.rb"
    content = File.read(routes_path)


    update_routes = <<~RUBY
      resources :passwords, param: :token
        resource :registrations, only: [ :new, :create ]
    RUBY
    
    # Add authentication routes
    content.gsub!(/resources :passwords, param: :token/, update_routes)

    File.write(routes_path, content)

  end
end
