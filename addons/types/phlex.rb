class PhlexAddon < Base

  def self.install
    run "bundle add phlex-rails"
    run "rails generate phlex:install"
  end
end
