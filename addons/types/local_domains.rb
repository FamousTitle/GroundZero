class LocalDomainsAddon < Base
  def self.install
    # This runs AFTER template files are copied by install_addons!
    puts "Configuring local domain setup for #{File.basename(Dir.pwd)}.dev..."
    
    app_name = File.basename(Dir.pwd)
    
    # Process the template files that were already copied
    process_template_file('docker-compose.override.yml', app_name)
    process_template_file('setup-local-domains.sh', app_name)
    process_template_file('LOCAL-DOMAINS.md', app_name)
    
    # Make setup script executable
    FileUtils.chmod(0755, 'setup-local-domains.sh') if File.exist?('setup-local-domains.sh')
    
    # Patch development.rb
    patch_development_config(app_name)
    
    # Run the setup script to configure /etc/hosts and SSL certificates
    puts "\n🔧 Running local domain setup script..."
    system('./setup-local-domains.sh')
    
    puts "✅ Local domain files configured for #{app_name}.dev"
  end
  
  private
  
  def self.process_template_file(filename, app_name)
    return unless File.exist?(filename)
    
    content = File.read(filename)
    updated_content = content.gsub('APP_NAME_PLACEHOLDER', app_name)
    File.write(filename, updated_content)
  end
  
  private
  
  def self.patch_development_config(app_name)
    dev_config_path = 'config/environments/development.rb'
    
    unless File.exist?(dev_config_path)
      puts "Warning: development.rb not found. Skipping domain configuration."
      return
    end
    
    content = File.read(dev_config_path)
    
    # Check if already patched
    if content.include?("#{app_name}.dev")
      puts "development.rb already configured for #{app_name}.dev"
      return
    end
    
    # Find the line "Rails.application.configure do" and insert after it
    patch = <<~RUBY
    
      # Allow requests from custom domain
      config.hosts << "#{app_name}.dev"
      config.hosts << ".#{app_name}.dev" # Allow subdomains
    RUBY
    
    updated = content.sub(/Rails\.application\.configure do\n/, "Rails.application.configure do#{patch}\n")
    
    File.write(dev_config_path, updated)
    puts "Successfully patched development.rb with #{app_name}.dev configuration"
  end
end
