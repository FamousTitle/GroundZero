#!/usr/bin/env ruby

require 'fileutils'
require 'find'

# Get the directory where the script is located for addons path
script_dir = File.dirname(File.expand_path(__FILE__))
addons_dir = "#{script_dir}/addons/types"

require_relative "#{script_dir}/addons/base"

# Load all addon files from the start
Dir.glob(File.join(addons_dir, "*.rb")).each do |addon_file|
  require_relative addon_file
end

CMD_IN_CONTAINER = "docker compose run --rm --remove-orphans web-rails bash -c "

# Check if required tools are installed
# Initialize an array to store missing tools
missing_tools = []

# Define tools to check
tools = ["ruby", "rails", "docker", "yarn"]

# Check each tool
tools.each do |command_name|
  # Check if command exists
  if !system("which #{command_name} > /dev/null 2>&1")
    missing_tools << command_name
  end
end

# Check if any tools are missing and display them
if !missing_tools.empty?
  puts "The following tools are not installed: #{missing_tools.join(' ')}"
  exit 1
end

# Check if app name argument is provided
if ARGV.empty?
  puts "Error: Please provide an application name as an argument"
  puts "Usage: #{$PROGRAM_NAME} APP_NAME"
  exit 1
end

app_name = ARGV[0]

# If app_name directory already exists, prompt if it is ok to overwrite
# If yes, delete the folder
if Dir.exist?(app_name)
  print "Directory #{app_name} already exists. Overwrite? (y/n) "
  # Use $stdin.gets instead of gets to avoid issues with directory names
  reply = $stdin.gets.chomp.downcase
  if reply != 'y'
    exit 1
  end
  FileUtils.rm_rf(app_name)
end

# Create new Rails application
puts "Creating new Rails application: #{app_name}"
system("rails new #{app_name} -d=postgresql --skip-docker -T --skip-system-test --javascript=esbuild")

# Copy template files
puts "Copying template files to #{app_name}/"

# Get the directory where the script is located
script_dir = File.dirname(File.expand_path(__FILE__))
template_dir = "#{script_dir}/templates"

# Get current working directory where the app will be created
cwd = Dir.pwd
app_dir = "#{cwd}/#{app_name}"

# Copy all files from templates directory to app directory, preserving structure
puts "Copying template files..."
FileUtils.mkdir_p(app_dir) unless Dir.exist?(app_dir)

# Simple recursive copy function that maintains directory structure
def copy_recursively(source_path, target_path, base_dir)
  # Create the target directory if it doesn't exist
  FileUtils.mkdir_p(target_path) unless Dir.exist?(target_path)
  
  # Copy all files and directories
  Dir.glob(File.join(source_path, "*"), File::FNM_DOTMATCH) do |entry|
    basename = File.basename(entry)
    # Skip . and .. directories
    next if basename == '.' || basename == '..'
    
    target = File.join(target_path, basename)
    
    if File.directory?(entry)
      # Recursively copy directories
      copy_recursively(entry, target, base_dir)
    else
      # Copy files
      relative_path = entry.sub(base_dir + '/', '')
      puts "Copying #{relative_path}"
      FileUtils.cp(entry, target)
    end
  end
end

# Start the recursive copy
copy_recursively(template_dir, app_dir, template_dir)

# add *.local.env to .gitignore
system("echo '*.local.env' >> #{app_dir}/.gitignore")

puts "Template files copied successfully"

# inside web-rails if there are permission issues
puts "Changing to application directory: #{app_dir}"
Dir.chdir(app_dir) do

  puts "docker-compose.yml - use unique volume names per project"
  docker_compose_path = "docker-compose.yml"
  content = File.read(docker_compose_path)
  content.gsub!(/bundled_gems_web_rails/, "bundled_gems_web_rails_#{app_name}")
  File.write(docker_compose_path, content)

  system("#{CMD_IN_CONTAINER} 'sudo chown -R rails:1000 /app/vendor/gems'")
  system("#{CMD_IN_CONTAINER} 'bundle add dotenv --group=development'")
  system("#{CMD_IN_CONTAINER} 'yarn install'")
  system("bin/container db_clean")
end
puts "Fixed permissions!"

# Process addons if specified
addons = []

ARGV.each_with_index do |arg, index|
  if index > 0
    if arg == "--all"
      # If --all flag is provided, find all available addons
      addon_files = Dir.glob(File.join(File.dirname(__FILE__), 'addons/types/*.rb'))
      addons = addon_files.map do |file|
        File.basename(file, '.rb')
      end
      break
    elsif arg.start_with?("addons=") || arg.start_with?("a=") || arg.start_with?("-addons=") || arg.start_with?("-a=")
      addon_list = arg.split("=")[1]
      addons = addon_list.split(",")
      break
    end
  end
end

if !addons.empty?
  puts "\nInstalling addons: #{addons.join(', ')}"
  
  Dir.chdir(app_dir) do
    addons.each do |addon|
      addon_name = addon.downcase
      class_name = "#{addon.capitalize}Addon"
      
      if Object.const_defined?(class_name)
        puts "Installing #{addon}..."
        
        # Call the install method on the addon class
        klass = Object.const_get(class_name)
        klass.install
        
        puts "#{addon} installed successfully!"
      else
        puts "Warning: Addon '#{addon}' not found or not properly defined."
      end
    end
  end
  puts "All addons installed successfully!"
else
  puts "No addons specified."
end

Dir.chdir(app_dir) do
  system("git add .")
  system("git commit -m 'Initial Commit'")
  system("git branch -M main")
end

puts "Setup complete!"
