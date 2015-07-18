require 'i3rb/api'
require 'i3rb/dmenu'

module I3
  module CLI

    include I3::API
    include I3::DMenu

    def self.run(args)
      dmenu = DMenu.get_instance
      args.map! do |arg|
        if arg == "_stdin_"
          $stdin.readline.chomp
        elsif arg == "_dmenu_"
          dmenu.get_string
        else
          arg
        end
      end
      
      #$debug = true
      
      driver = Object.new.extend I3::API
      class << driver
        
        def method_missing(m,*a,&b)
          i3send "#{m} #{a.join(" ")}", &b
        end
      end
      
      args.join(" ").split(",").each do |cmd|
        cmd, args = cmd.split[0], cmd.split[1..-1]
        args = [] if args == [""]
        $logger.debug "Driver##{cmd}(#{args.inspect})"
        if args.any?
          puts driver.send cmd, *args
        else
          puts driver.send cmd
        end
      end
    end

    def run(args = ARGV)
      CLI.run args
    end

  end
end