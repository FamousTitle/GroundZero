class RspecAddon < Base
  def self.install
    # rspec
    run "bundle add rspec-rails --group development,test"
    run "rails generate rspec:install --force"

    # factory bot
    run "bundle add factory_bot --group development,test"

    # capybara
    run "bundle add capybara --group development,test"
    
    # Add Capybara configuration to rails_helper.rb after rspec/rails
    rails_helper_path = 'spec/rails_helper.rb'
    if File.exist?(rails_helper_path)
      content = File.read(rails_helper_path)
      
      # Insert capybara/rails after rspec/rails
      unless content.include?("require 'capybara/rails'")
        content.gsub!(/require 'rspec\/rails'/, "require 'rspec/rails'\nrequire 'capybara/rails'")
        File.write(rails_helper_path, content)
        puts "✅ Added Capybara to rails_helper.rb"
      end
    end
    
    # Add capybara/rspec to spec_helper.rb at the top
    spec_helper_path = 'spec/spec_helper.rb'
    if File.exist?(spec_helper_path)
      content = File.read(spec_helper_path)
      
      unless content.include?("require 'capybara/rspec'")
        # Insert at the beginning after the comment
        content.sub!(/^(# [^\n]+\n)/, "\\1require 'capybara/rspec'\n")
        File.write(spec_helper_path, content)
        puts "✅ Added Capybara to spec_helper.rb"
      end
    end

  end
end
