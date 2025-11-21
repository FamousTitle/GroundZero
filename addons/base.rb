require 'shellwords'

class Base
  CMD_IN_CONTAINER = "docker compose run --rm web-rails bash -c"

  def self.run(cmd)
    success = system("#{CMD_IN_CONTAINER} #{Shellwords.escape(cmd)}")
    unless success
      puts "\n❌ Error: Command failed with exit code #{$?.exitstatus}"
      puts "   Command: #{cmd}"
      exit 1
    end
    success
  end

end
