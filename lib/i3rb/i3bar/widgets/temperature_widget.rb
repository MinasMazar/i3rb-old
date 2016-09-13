# coding: utf-8
module I3
  module Bar
    module Widgets

      class Temperature < Widget
        def self.get_instance
          new 10
        end
        def initialize(timeout)
          super :temperature, timeout do |w|
            w.kill unless `sensors`.gsub("\n", " ").match(/acpitz/)
            out = "Temp: "
            if md = `sensors`.gsub("\n", " ").match(/temp1:\s+(\S+)°C\s+\(crit\s+=\s+(\S+)°C\)/)
              temp, crit = md[1].to_f, md[2].to_f
              out += "#{temp}"
              w.color = "#FF0000" if temp >= crit
              w.color = "#FFFF00" if temp < crit - 8
              w.color = "#00FF00" if temp < crit - 16
            else
              out += "NONE"
              w.color = "#FF0000"
            end
            [ out ] * 2
          end
        end
      end

    end
  end
end
