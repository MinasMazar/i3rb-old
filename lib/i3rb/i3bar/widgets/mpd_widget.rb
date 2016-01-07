# coding: utf-8
module I3
  module Bar
    module Widgets

      class MPD < Widget
        def self.get_instance
          new "localhost", 6
        end
        def initialize(host, timeout)
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
              system "mpc -h #{host} toggle"
            end
          end
        end
      end

    end
  end
end
