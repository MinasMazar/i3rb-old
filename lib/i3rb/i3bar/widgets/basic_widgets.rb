# coding: utf-8
require 'i3rb/i3bar/widgets/mpd_widget'
require 'i3rb/i3bar/widgets/cmus_widget'
require 'i3rb/i3bar/widgets/hostname_widget'
require 'i3rb/i3bar/widgets/calendar_widget'
require 'i3rb/i3bar/widgets/wifi_widget'
require 'i3rb/i3bar/widgets/battery_widget'
require 'i3rb/i3bar/widgets/temperature_widget'


 module I3
  module Bar
    module Widgets
      BASIC = [ Hostname, Calendar, WiFi, Battery, MPD, CMUS ]

      def add_basic_widgets
	add_widgets BASIC.map(&:get_instance)
      end

      def add_widget(widget)
        widget = [ widget ] unless widget.kind_of? Array
        widget.each do |w|
          raise ArgumentError.new "#{w.class} is not a #{Widget} subclass" unless w.kind_of? Widget
          @widgets << w
          define_singleton_method w.name do
            self.widget w.name
          end
        end
      end

      alias :add_widgets :add_widget

      def widget(w)
        widgets.find { |_w| _w.name == w }
      end

      def widgets
	@widgets.flatten!
	@widgets.reject! {|w| !w.kind_of? Widget }
	@widgets.sort_by! {|w| w.pos }
	@widgets.uniq! {|w| w.name }
	@widgets
      end

    end
  end
end
