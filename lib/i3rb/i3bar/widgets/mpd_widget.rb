# coding: utf-8
module I3
  module Bar
    module Widgets

      class MPD < Widget
        def self.get_instance
          new "localhost", 6
        end
        attr_accessor :host
        def initialize(host, timeout)
          @host = host
          super :mpd, timeout do |w|
            ret = `mpc -h #{host}`.split("\n")
            if ret.size > 1
              track = ret[0]
              status = ret[1].split[0]
              "🎜 #{track} #{status} 🎜"
            else
              "🎜 MPD not running 🎜"
            end
          end
          add_event_callback do |w,e|
            if e.button == 1
              w.exec_mpc_command "toggle"
            end
          end
        end
        def mpc_command(cmd)
          "mpc -h #{host} #{cmd}"
        end
        def exec_mpc_command(cmd)
          system_exec mpc_command cmd
        end
      end

    end
  end
end
