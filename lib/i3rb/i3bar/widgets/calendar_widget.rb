module I3
  module Bar
    module Widgets

      class Calendar < Widget
        def self.get_instance
          new 1
        end
        def initialize(timeout)
          super :calendar, timeout do
            Time.new.strftime('%d-%m-%Y %H:%M:%S')
          end
        end
      end

    end
  end
end
