module I3
  module CLI

    include I3::API

    def self.run(args)
      args.map! do |arg|
        if arg == "_stdin_"
          $stdin.readline.chomp
        else
          arg
        end
      end
      
      #$debug = true
      
      driver = Object.new.extend I3::API
      class << driver
        def current_workspace_name
          current_workspace["name"]
        end
        
        def method_missing(m,*a,&b)
          i3send "#{m} #{a.join(" ")}", &b
        end
      end
      
      args.join(" ").split(",").each do |cmd|
        cmd, args = cmd.split[0], cmd.split[1..-1]
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