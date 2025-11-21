class Local_domainsAddon < BaseAddon
  def self.install
    puts "Setting up local domain configuration..."
    
    app_name = File.basename(Dir.pwd)
    script_dir = File.expand_path('../../..', __dir__)
    template_dir = File.join(script_dir, 'addons', 'templates', 'local_domains')
    
    # Read and process docker-compose.override.yml
    override_template = File.read(File.join(template_dir, 'docker-compose.override.yml'))
    override_content = override_template.gsub('APP_NAME_PLACEHOLDER', app_name)
    File.write('docker-compose.override.yml', override_content)
    
    # Read and process setup-local-domains.sh
    setup_template = File.read(File.join(template_dir, 'setup-local-domains.sh'))
    setup_content = setup_template.gsub('APP_NAME_PLACEHOLDER', app_name)
    File.write('setup-local-domains.sh', setup_content)
    FileUtils.chmod(0755, 'setup-local-domains.sh')
    
    # Read and process LOCAL-DOMAINS.md
    docs_template = File.read(File.join(template_dir, 'LOCAL-DOMAINS.md'))
    docs_content = docs_template.gsub('APP_NAME_PLACEHOLDER', app_name)
    File.write('LOCAL-DOMAINS.md', docs_content)
    
    # Patch development.rb
    patch_development_config(app_name)
    
    puts "✅ Local domain files generated for #{app_name}.dev"
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
