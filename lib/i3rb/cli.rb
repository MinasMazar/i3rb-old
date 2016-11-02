require 'thor'
require 'pry'
require 'i3rb/config/cli'

$debug = true

module I3
  class Cli < Thor

    no_commands do
      include I3::API
    end

    desc "pry [script]", "Start pry session within i3 ipc connection, eventually pre-load a script"
    def pry(script = nil)
      if script && File.exist?(script)
        load script
      end
      binding.pry
    end

    desc "config", "Operate i3 configurations"
    subcommand :config, I3::Config::Cli

  end
end
