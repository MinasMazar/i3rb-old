require 'json'

module I3
  module Bar

    module EventHandler

      def instance
        if respond_to? :name
          "#{name}-#{__id__}"
        else
          "#{self.class}-#{__id__}"
        end
      end

      def event_callbacks
        @ecbs ||= []
      end

      def add_event_callback(&ecb)
        event_callbacks << ecb
      end

      def notify_event(ev)
        return nil unless is_receiver?(ev) && !respond_to_all?
        notify_event! ev
      end

      def notify_event!(ev)
        event_callbacks.map do |cb|
          cb.call self, ev
        end
      end

      def is_receiver?(ev)
        ev["instance"] == instance
      end

      def respond_to_all?
        @options[:respond_to_all]
      end

    end

    class Widget

      include EventHandler

      attr_accessor :name, :timeout, :block
      attr_accessor :pos, :color

      def initialize(name, timeout, options = {}, &proc)
        @name = name
        @text = name
        @active = true
        @options = options
        @color = @options[:color] if @options[:color]
        @pos = @options[:pos] if @options[:pos]
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
        h.merge! "color" => self.color if @color
        h.merge! "name" => name
        h.merge! "instance" => instance
        h
      end

    end

    class Instance

      include EventHandler

      attr_reader :options

      def initialize(stream_in, stream_out, options = {})
        @stream_in, @stream_out = stream_in, stream_out
        @widgets = []
        @header = { "version"=> 1, "stop_signal"=> 10, "cont_signal"=> 12, "click_events"=> true }
        @options = options
        [ "stop_signal", "cont_signal", "click_events"].each do |opt|
          @header[opt] = options[opt] if options.include? opt
        end
        #@header = { "version" => 1 }
        yield self if block_given?
      end

      def add_widget(widget)
        @widgets << widget
      end

      alias :add_widgets :add_widget

      def widget(w)
        widgets.find { |_w| _w.name == w }
      end

      def widgets
        @widgets.flatten.reject {|w| !w.kind_of? Widget }
      end

      def run(secs)
        start_widgets
        stdout_attach secs
      end

      def start_widgets
        widgets.each { |w| w.run }
      end

      def stop_widgets
        widgets.each { |w| w.kill }
      end

      def start_events_capturing
        @event_th = Thread.new do
          read_event_loop
        end
      end

      attr_reader :event, :event_th

      def stop_events_capturing
        @event = nil
        @event_th && @event_th.kill
      end

      def stdout_attach(sec)
        begin
          @stream_out.write JSON.generate(@header) + "\n"
          sleep 0.5
          @stream_out.write "[" + "\n"
          sleep 0.5
          @stream_out.write [].to_s + "\n"
          sleep 0.8
          loop do
            @stream_out.write "," + JSON.generate(widgets.map(&:to_i3bar_protocol)) + "\n"
            @stream_out.flush
            sleep sec
          end
        rescue Interrupt
        ensure
          @stream_out.write "]\n"
          @stream_out.flush
        end
      end

      private

      def read_event_loop
        loop do
          l = @stream_in.readline.chomp
          if md = l.match(/(\{.+\})/)
            begin
              @event = JSON.parse md[1]
              notify_event! @event
              widgets.map { |w| w.notify_event @event }
            rescue
              nil
            end
          end
        end
      end

    end

    module Widgets
    end

    require 'i3rb/bar/widgets/basic_widgets'

    def self.get_instance(stream_in = nil, stream_out = nil, options = {})
      stream_in ||= $stdin
      stream_out ||= $stdout
      init_proc = Proc.new if block_given?
      Instance.new stream_in, stream_out, options, &init_proc
    end

  end
end
