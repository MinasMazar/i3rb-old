module I3
  module Bar
    module Widgets

      class Hostname < Widget
        def self.get_instance
          new
        end
        def initialize
          super :hostname, 0 do
            [ `hostname`.chomp ] * 2
          end
        end
      end

    end
  end
end
