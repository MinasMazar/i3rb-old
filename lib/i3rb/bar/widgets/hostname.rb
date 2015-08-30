module I3
  module Bar
    module Widgets

      HOSTNAME = Widget.new 'hostname', 100, color: "#FFFFFF" do
        [ `whoami`.chomp, '@',  `hostname`.chomp ].join
      end

    end
  end
end