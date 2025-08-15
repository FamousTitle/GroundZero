# Ground Zero

## Prerequisites (local machine)

- Docker
- Docker Compose
- Yarn
- Ruby v3.4.1
- Rails v8.0.2

## Make script executable

```bash
chmod +x setup.rb
```

## Run script

```bash
./setup.rb APP_NAME
```

## Using Addons

You can include addons when creating a new application:

```bash
./setup.rb APP_NAME addons=phlex,alpinejs
```

Or use the shorthand:

```bash
./setup.rb APP_NAME a=phlex,alpinejs
```

Or install all addons:

```bash
./setup.rb APP_NAME --all
```

### Creating Custom Addons

You can create your own addons by adding a Ruby file to the `addons` directory:

1. Create a file named `your_addon_name.rb` in the `addons` directory
2. Define a class named `YourAddonNameAddon` (e.g., for an addon named "phlex", create a class named `PhlexAddon`)
3. Implement a class method called `install` that contains the installation logic
4. Use `run` calls to run Rails or bundle commands

Example addon file (`addons/tailwindcss.rb`):
```ruby
class TailwindcssAddon
  def self.install
    run("bundle add tailwindcss-rails")
    run("rails tailwindcss:install")
  end
end
```

### Fresh App

If you are starting a new ground_zero app, make sure you setup by running `bin/container fresh_app`
