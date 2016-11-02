
module I3
  module Config

    class Cli < Thor

      desc "backup <destination>", "Do a backup of ~/.i3/config file"
      def backup(destination = nil)
        raise NotImplementedError
      end

    end

  end
end
