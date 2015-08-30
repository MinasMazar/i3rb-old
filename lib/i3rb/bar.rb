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
          self.send "#{k}=", v if self.respond_to? "#{k}="
        end
        @timeout = timeout.to_i.abs
        @timeout = 0 if options[:once] == true
        @proc = proc
      end

      def pos
        @pos || -1
      end

      def kill
        @run_th && @run_th.kill
      end

      def run
        @run_th = Thread.new do
          loop do
            @text = @proc.call self
            break if @timeout <= 0
            sleep @timeout.to_i
          end
        end
      end

      def to_i3bar_protocol
        h = {
          "full_text" => @text
        }
        h.merge! "color" => @color if @color
        h.merge! "name" => name if @name
        h.merge! "instance" => "#{name}-#{hash}" if @name
        h
      end

    end

    class Instance

      attr_reader :widgets

      def initialize
        @widgets = []
        #@header = { "version"=> 1, "stop_signal"=> 10, "cont_signal"=> 12, "click_events"=> true }
        @header = { "version" => 1 }
      end

      def add_widget(widget)
        @widgets << widget
        normalize_widgets_array
      end

      alias :add_widgets :add_widget

      def run(secs)
        start_widgets
        stdout_attach secs
      end

      def start_widgets
        @widgets.each { |w| w.run }
      end

      def stop_widgets
        @widgets.each { |w| w.kill }
      end

      def read_event
        $stdin.read
      end

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

      private

      def normalize_widgets_array
        @widgets.replace @widgets.flatten.select {|w| w.kind_of? Widget }
      end

    end

    module Widgets
    end

    require 'i3rb/bar/widgets/basic_widgets'

    def self.get_instance
      Instance.new
    end

  end
end
