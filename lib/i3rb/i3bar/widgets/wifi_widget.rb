module I3
  module Bar
    module Widgets

      class WiFi < Widget
        def self.get_instance
          new 4
        end
        def initialize(timeout)
          super :wifi, timeout do |w|
            iwc_out = `iwconfig 2>/dev/null`.gsub("\n", " ")
            out = "WiFi: "
            if md = iwc_out.match(/ESSID:"(.+)"/)
              w.color = "#00FF00"
              out += "#{md[1]} "
              if md = iwc_out.match(/Link Quality=(\d+)\/(\d+)/)
                signal, range = md[1].to_i, md[2].to_i
                signal_percent = signal * 100 / range
                out += " (#{signal_percent}%) "
              end
            else
              out += "down "
              w.color = "#FF0000"
            end
            out
          end
        end
      end

    end
  end
end
