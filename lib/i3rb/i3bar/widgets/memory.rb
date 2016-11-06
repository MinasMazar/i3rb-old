module I3
  module Bar
    module Widgets

      class Memory < Widget

        def self.get_instance
          new 10
        end

        def initialize(timeout)
          super :memory, timeout do |w|
            txt = `free -h`.split("\n").map {|i| i.split}.tap {|t| t[0].unshift("X") }
            txt.map { |r| r[3].capitalize }.join(" ")
          end
        end
      end
    end
  end
end
