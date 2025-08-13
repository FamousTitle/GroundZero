class AlpinejsAddon < Base

  def self.install
    run "yarn add alpinejs"

    update_app_javascript = <<~RUBY

      import Alpine from 'alpinejs';
      window.Alpine = Alpine; // Optional, but useful for dev tools
      Alpine.start();
    RUBY

    File.open("app/javascript/application.js", "a") do |file|
      file.puts update_app_javascript
    end
  end

end
