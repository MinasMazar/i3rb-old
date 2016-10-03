module I3
  module Bar
    module Widgets

      class WiFi < Widget
        def self.get_instance
          new 4
        end
        def initialize(timeout)
          super :wifi, timeout do |w|
            iwc_out = block_given? ? yield : `iwconfig 2>/dev/null`
            iwc_out = iwc_out.gsub("\n", " ")
            out = "WiFi: "
            if md = iwc_out.match(/ESSID:"(.+)"/)
              w.color = "#00FF00"
              out += "#{md[1]} "
              if md = iwc_out.match(/Link Quality=(\d+)\/(\d+)/)
                signal, range = md[1].to_i, md[2].to_i
                signal_percent = signal * 100 / range
                out += " (#{signal_percent}%) "
              end
              signal_color = {
                (1..20) => "#FF0000",
                (21..40) => "#FFFF00",
                (41..60) => "#8ae429",
                (61..80) => "#00EE00",
                (81..100) => "#00FF00"
              }
              signal_color = signal_color.map { |range,color| range.include?(signal_percent) ? color : nil }.compact.first
              w.color = signal_color
              [ out, "WiFi: ON" ]
            else
              w.color = "#FF0000"
              out += "down "
            end
          end
        end
      end

    end
  end
end
