require 'i3rb/api'
require 'i3rb/dmenu'

module I3
  module CLI

    module Macros

      def get_workspaces
        super.map { |ws| ws["name"] }
      end
    end

    include I3::API
    include I3::DMenu
    include I3::CLI::Macros

    def run(args)
      dmenu = DMenu.get_instance
      args.map! do |arg|
        if arg == "_stdin_"
          $stdin.readline.chomp
        elsif arg == "_dmenu_ws_"
          dmenu.items.concat get_workspaces
          dmenu.get_string
        elsif arg == "_dmenu_"
          dmenu.get_string
        else
          arg
        end
      end
      
      #$debug = true
      
      driver = Object.new
      driver.extend I3::API
      driver.extend I3::CLI::Macros
      
      args.join(" ").split(",").each do |cmd|
        cmd = cmd.split
        meth, args = cmd.shift, cmd
        args = [] if args == [""]
        $logger.debug "Driver##{meth}(#{args.inspect})"
        if args.any?
          puts self.send meth, args.join(" ")
        else
          puts self.send meth
        end
      end
    end

  end
end