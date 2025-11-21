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

def ensure_tools!
  missing_tools = []
  tools = ["ruby", "rails", "docker", "yarn"]
  tools.each do |command_name|
    missing_tools << command_name unless system("which #{command_name} > /dev/null 2>&1")
  end
  unless missing_tools.empty?
    puts "The following tools are not installed: #{missing_tools.join(' ')}"
    exit 1
  end
end

def create_app!(app_name)
  if Dir.exist?(app_name)
    print "Directory #{app_name} already exists. Overwrite? (y/n) "
    reply = $stdin.gets.chomp.downcase
    exit 1 if reply != 'y'
    FileUtils.rm_rf(app_name)
  end

  puts "Creating new Rails application: #{app_name}"

  database = "postgresql"
  if ARGV.include?("-d=") || ARGV.include?("--database=")
    ARGV.each do |arg|
      if arg.start_with?("-d=") || arg.start_with?("--database=")
        database = arg.split("=")[1]
        break
      end
    end
  end

  if ARGV.include?("--api") || ARGV.include?("-api")
    system("rails new #{app_name} -d=#{database} --skip-docker -T --skip-system-test --api --javascript=esbuild")
  else
    system("rails new #{app_name} -d=#{database} --skip-docker -T --skip-system-test --javascript=esbuild")
  end

end

def copy_recursively(source_path, target_path, base_dir)
  FileUtils.mkdir_p(target_path) unless Dir.exist?(target_path)
  Dir.glob(File.join(source_path, "*"), File::FNM_DOTMATCH) do |entry|
    basename = File.basename(entry)
    next if basename == '.' || basename == '..'

    target = File.join(target_path, basename)
    if File.directory?(entry)
      copy_recursively(entry, target, base_dir)
    else
      relative_path = entry.sub(base_dir + '/', '')
      puts "Copying #{relative_path}"
      FileUtils.cp(entry, target)
    end
  end
end

def copy_base_templates!(script_dir, app_dir)
  template_dir = File.join(script_dir, 'templates')
  puts "Copying template files to #{app_dir}/"
  puts "Copying template files..."
  FileUtils.mkdir_p(app_dir) unless Dir.exist?(app_dir)
  copy_recursively(template_dir, app_dir, template_dir)
  system("echo '*.local.env' >> #{app_dir}/.gitignore")
  puts "Template files copied successfully"
end

def prepare_environment!(app_dir, app_name)
  puts "Changing to application directory: #{app_dir}"
  Dir.chdir(app_dir) do
    # Create .web-rails.local.env file if it doesn't exist
    unless File.exist?('.web-rails.local.env')
      FileUtils.touch('.web-rails.local.env')
      puts "Created .web-rails.local.env file"
    end
    
    # remove any existing containers
    puts "Deleting existing containers: #{app_name}"
    system("docker container ls | grep #{app_name} | awk '{print $1}' | xargs docker container rm -f 2>/dev/null")

    # remove any existing volumes
    puts "Deleting existing volumes: #{app_name}"
    system("docker volume ls | grep #{app_name} | awk '{print $2}' | xargs docker volume rm -f 2>/dev/null")

    system("#{CMD_IN_CONTAINER} 'sudo chown -R rails:1000 /app/vendor/gems'")
    system("#{CMD_IN_CONTAINER} 'bundle add dotenv --group=development'")
    system("#{CMD_IN_CONTAINER} 'yarn install'")
    system("bin/container db_clean")
  end
  puts "Fixed permissions!"
end

def parse_addons(args)
  addons = []
  args.each_with_index do |arg, index|
    next if index == 0
    if arg == "--all" || arg == "-all"
      addon_files = Dir.glob(File.join(File.dirname(__FILE__), 'addons/types/*.rb'))
      addons = addon_files.map { |file| File.basename(file, '.rb') }
      break
    elsif arg.start_with?("addons=") || arg.start_with?("a=") || arg.start_with?("-addons=") || arg.start_with?("-a=")
      addon_list = arg.split("=")[1]
      addons = addon_list.split(",")
      break
    end
  end
  addons
end

def install_addons!(app_dir, addons, script_dir)
  return if addons.empty?

  puts "\nInstalling addons: #{addons.join(', ')}"
  Dir.chdir(app_dir) do
    addons.each do |addon|
      addon_name = addon.downcase
      # Convert addon name to proper class name (e.g., local_domains -> LocalDomains)
      class_name = "#{addon_name.split('_').map(&:capitalize).join}Addon"

      if Object.const_defined?(class_name)
        puts "Installing #{addon}..."
        
        # Copy addon templates FIRST (before running install)
        addon_template_dir = File.join(script_dir, 'addons', 'templates', addon_name)
        if Dir.exist?(addon_template_dir)
          puts "Copying addon templates from addons/templates/#{addon_name} to #{app_dir}..."
          copy_recursively(addon_template_dir, app_dir, addon_template_dir)
        end
        
        # Then run the addon's install method
        klass = Object.const_get(class_name)
        klass.install

        puts "#{addon} installed successfully!"
      else
        puts "Warning: Addon '#{addon}' not found or not properly defined."
      end
    end
  end
  puts "All addons installed successfully!"
end

def remove_css_from_application_layout
  # in the app_dir, locate app/views/layouts/application.html.erb and remove all the css classes in the main element
  app_name = ARGV[0]
  return unless app_name

  app_dir = File.join(Dir.pwd, app_name)
  layout_path = File.join(app_dir, 'app', 'views', 'layouts', 'application.html.erb')

  unless File.exist?(layout_path)
    puts "Warning: Layout file not found at #{layout_path}. Skipping final cleanup."
    return
  end

  content = File.read(layout_path)
  updated = content.sub(/<main[^>]*>/m, '<main>')

  if updated == content
    puts "Note: No changes made to <main> tag."
  else
    File.write(layout_path, updated)
    puts "Simplified <main> tag in #{layout_path}."
  end
end

def finalize_git!(app_dir)
  Dir.chdir(app_dir) do
    system("git add .")
    system("git commit -m 'Initial Commit'")
    system("git branch -M main")
  end
end

def main
  ensure_tools!

  if ARGV.empty? || ARGV[0] == "--help" || ARGV[0] == "-h" || ARGV[0] == "help"
    puts "Usage: #{$PROGRAM_NAME} APP_NAME [OPTIONS]"
    puts ""
    puts "Options:"
    puts "  -d=DATABASE, --database=DATABASE    Database to use (default: postgresql)"
    puts "  --api, -api                         Create API-only application"
    puts "  addons=ADDON1,ADDON2                Install specific addons"
    puts "  -a=ADDON1,ADDON2                    Shorthand for addons="
    puts "  --all, -all                         Install all available addons"
    puts "  --help, -h, help                    Show this help message"
    puts ""
    puts "Available addons:"
    addon_files = Dir.glob(File.join(File.dirname(__FILE__), 'addons/types/*.rb'))
    addon_names = addon_files.map { |file| "  - #{File.basename(file, '.rb')}" }
    puts addon_names.sort.join("\n")
    puts ""
    puts "Examples:"
    puts "  #{$PROGRAM_NAME} myapp"
    puts "  #{$PROGRAM_NAME} myapp --api"
    puts "  #{$PROGRAM_NAME} myapp addons=phlex,authenticate"
    puts "  #{$PROGRAM_NAME} myapp --all"
    exit 0
  end

  app_name = ARGV[0]
  script_dir = File.dirname(File.expand_path(__FILE__))
  cwd = Dir.pwd
  app_dir = File.join(cwd, app_name)

  create_app!(app_name)
  copy_base_templates!(script_dir, app_dir)
  prepare_environment!(app_dir, app_name)

  addons = parse_addons(ARGV)
  install_addons!(app_dir, addons, script_dir)
  
  remove_css_from_application_layout

  finalize_git!(app_dir)
  puts "Setup complete!"
end

main
