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
      
      # Replace ENV['RAILS_ENV'] ||= 'test' with ENV['RAILS_ENV'] = 'test'
      content.gsub!(/ENV\['RAILS_ENV'\] \|\|= 'test'/, "ENV['RAILS_ENV'] = 'test'")
      
      # Insert capybara/rails after rspec/rails
      unless content.include?("require 'capybara/rails'")
        content.gsub!(/require 'rspec\/rails'/, "require 'rspec/rails'\nrequire 'capybara/rails'")
      end
      
      File.write(rails_helper_path, content)
      puts "✅ Added Capybara to rails_helper.rb and set RAILS_ENV"
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

    # Add RSpec to GitHub Actions CI workflow
    add_rspec_to_ci_workflow

  end
  
  private
  
  def self.add_rspec_to_ci_workflow
    ci_path = '.github/workflows/ci.yml'
    
    return unless File.exist?(ci_path)
    
    content = File.read(ci_path)
    
    # Check if rspec is already in the workflow
    return if content.include?('bundle exec rspec')
    
    # Add the test job (using regular heredoc to preserve exact indentation)
    rspec_job = <<YAML

  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:18
        env:
          POSTGRES_USER: rails
          POSTGRES_PASSWORD: rails
          POSTGRES_DB: test
        ports:
          - 5432:5432
        options: --health-cmd="pg_isready" --health-interval=10s --health-timeout=5s --health-retries=3

    env:
      RAILS_ENV: test
      DATABASE_URL: postgres://rails:rails@localhost:5432/test
      POSTGRES_USER: rails
      POSTGRES_PASSWORD: rails
      POSTGRES_DB: test
      POSTGRES_HOST: localhost
      DATABASE_HOST: localhost
      DATABASE_PORT: 5432
      DATABASE_USERNAME: rails
      DATABASE_PASSWORD: rails
      DATABASE_NAME: test

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true

      - name: Set up Node
        uses: actions/setup-node@v4
        with:
          node-version-file: '.node-version'
          cache: 'yarn'

      - name: Install dependencies
        run: |
          yarn install --frozen-lockfile

      - name: Set up database
        run: |
          bin/rails db:create db:schema:load

      - name: Run tests
        run: |
          bundle exec rspec
YAML
    
    # Append to the end of the file
    content << rspec_job
    
    File.write(ci_path, content)
    puts "✅ Added RSpec test job to .github/workflows/ci.yml"
  end
end
