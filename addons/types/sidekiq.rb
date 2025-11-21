class SidekiqAddon < Base

  def self.install
    # Add sidekiq gem
    run "bundle add sidekiq"

    # Create config/initializers/sidekiq.rb with Redis configuration
    sidekiq_config = <<~RUBY
      Sidekiq.configure_server do |config|
        config.redis = { url: ENV.fetch('REDIS_URL', 'redis://redis:6379/0') }
      end

      Sidekiq.configure_client do |config|
        config.redis = { url: ENV.fetch('REDIS_URL', 'redis://redis:6379/0') }
      end
    RUBY
    
    File.write('config/initializers/sidekiq.rb', sidekiq_config)
    puts "✅ Created config/initializers/sidekiq.rb"

    # Update docker-compose.yml to enable sidekiq and redis services
    docker_compose_path = "docker-compose.yml"
    content = File.read(docker_compose_path)
    
    # Uncomment the sidekiq service
    content.gsub!(/  # sidekiq:\n  #   <<: \*default\n  #   command: \"bundle exec sidekiq -q low -q default -c 25\" # comment out unless install sidekiq/, "  sidekiq:\n    <<: *default\n    command: \"bundle exec sidekiq -q low -q default -c 25\"")
    
    # Uncomment the redis service
    content.gsub!(/  # redis:\n  #   image: redis:8\.4\.0 # comment out unless install sidekiq/, "  redis:\n    image: redis:8.4.0")
    
    # Write the updated content back to the file
    File.write(docker_compose_path, content)
    
    puts "✅ Sidekiq and Redis services enabled in docker-compose.yml"
  end
end
