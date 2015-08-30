require 'json'

module I3
  module Bar

    class Widget

      attr_accessor :name, :timeout, :block
      attr_accessor :pos, :color

      def initialize(name, timeout, options = {}, &proc)
        @name = name
        @text = name
        @active = true
        options.each do |k,v|
          self.send "#{k}=", v
        end
        @timeout = timeout
        @proc = proc
      end

      def pos
        pos || -1
      end

      def stop
        @run_th && @run_th.kill
      end

      def run
        @run_th = Thread.new do
          loop do
            @text = @proc.call self
            sleep @timeout.to_i
          end
        end
      end

      def to_i3bar_protocol
        h = {
          "full_text" => @text,
          "color" => @color,
          "name" => name,
          "instance" => "#{name}-#{hash}"
        }
        h
      end

    end

    class Instance

      def initialize
        @widgets = []
        #@header = { "version"=> 1, "stop_signal"=> 10, "cont_signal"=> 12, "click_events"=> true }
        @header = { "version" => 1 }
      end

      def add_widget(widget)
        return nil unless widget.kind_of? Widget
        @widgets << widget
        widget
      end

      def run(secs)
        @widgets.each { |w| w.run }
        stdout_attach secs
      end

      def widgets_to_stdout
      end

      private

      def stdout_attach(sec)
        begin
          #$stdout.write JSON.generate(@header) + "\n"
          $stdout.write "{ \"version\": 1 }\n"
          sleep 0.5
          $stdout.write "[" + "\n"
          sleep 0.5
          $stdout.write [].to_s + "\n"
          sleep 0.8
          loop do
            $stdout.write "," + JSON.generate(@widgets.map(&:to_i3bar_protocol)) + "\n"
            $stdout.flush
            sleep sec
          end
          $stdout.write "]\n"
        rescue Interrupt
        ensure
          $stdout.write "]\n"
        end
      end

    end

    module Widgets
    end

    require 'i3rb/bar/widgets/hostname'

    def self.get_instance
      Instance.new
    end

  end
end
