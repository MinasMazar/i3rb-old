module I3
  module Bar
    module Widgets

      class Battery < Widget
        def self.get_instance
          new 20
        end
        def initialize(timeout)
          super :battery, timeout do |w|
            acpi_res = `acpi -b`
            if md = acpi_res.match(/Battery\s(\d+):\s(\w+),\s(\d+)%/)
              status = md[2]
              charging_percentage = md[3].to_i
              if  charging_percentage > 70
                w.color = "#00FF00"
              elsif charging_percentage > 30
                w.color = "#00FFFF"
              else
                w.color = "#FF0000"
              end
              [ "BATTERY: #{charging_percentage}% #{status}" ] * 2
            else
              w.kill
              false
            end
          end
        end
      end

    end
  end
end
