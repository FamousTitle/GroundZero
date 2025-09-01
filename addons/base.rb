require 'shellwords'

class Base
  CMD_IN_CONTAINER = "docker compose run --rm web-rails bash -c"

  def self.run(cmd)
    system("#{CMD_IN_CONTAINER} #{Shellwords.escape(cmd)}")
  end

end
