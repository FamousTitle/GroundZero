class RspecAddon < Base
  def self.install
    # rspec
    run "bundle add rspec-rails --group development,test"
    run "rails generate rspec:install --force"

    # factory bot
    run "bundle add factory_bot --group development,test"

    # capybara
    run "bundle add capybara --group development,test"
    
    # Add Capybara configuration to spec files
    run 'echo "require \'capybara/rails\'" | cat - spec/rails_helper.rb > temp && mv temp spec/rails_helper.rb'
    run 'echo "require \'capybara/rspec\'" | cat - spec/spec_helper.rb > temp && mv temp spec/spec_helper.rb'

  end
end
