class TailwindcssAddon < Base

  def self.install
    run "bundle add tailwindcss-ruby"
    run "bundle add tailwindcss-rails"
    
    # Create the tailwind directory and application.css file
    FileUtils.mkdir_p('app/assets/tailwind')
    File.write('app/assets/tailwind/application.css', '@import "tailwindcss";')
    
    run "rails tailwindcss:install --force"

    # Update docker-compose.yml to enable CSS service
    docker_compose_path = "docker-compose.yml"
    content = File.read(docker_compose_path)
    
    # Uncomment the CSS dependency line
    content.gsub!(/# - css # comment out unless install tailwindcss/, "- css")
    
    # Uncomment the CSS section
    content.gsub!(/  # css:\n  #   <<: \*default\n  #   command: \"bin\/rails tailwindcss:watch\" # comment out unless install tailwindcss/, "  css:\n    <<: *default\n    command: \"bin/rails tailwindcss:watch\"")
    
    # Write the updated content back to the file
    File.write(docker_compose_path, content)
  end
end
