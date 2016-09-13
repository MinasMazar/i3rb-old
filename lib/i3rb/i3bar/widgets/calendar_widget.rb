module I3
  module Bar
    module Widgets

      class Calendar < Widget
        def self.get_instance
          new '%d-%m-%Y %H:%M:%S', 1
        end
        attr_accessor :format
        def initialize(format, timeout)
          @format = format
          super :calendar, timeout do
            [ Time.new.strftime(format), Time.new.strftime("%H:%M") ]
          end
        end
      end

    end
  end
end
