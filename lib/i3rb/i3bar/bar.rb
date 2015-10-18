require 'json'
require 'i3rb/i3bar/event'
require 'i3rb/i3bar/widget'
require 'i3rb/i3bar/widgets/basic_widgets'

module I3
  module Bar
    class Instance

      include EventHandler
      include Widgets

      attr_reader :options

      def initialize(stream_in, stream_out, options = {})
        @stream_in, @stream_out = stream_in, stream_out
        @widgets = []
        @header = { "version"=> 1, "click_events"=> true }
        @options = options
        [ "stop_signal", "cont_signal", "click_events"].each do |opt|
          @header[opt] = options[opt] if options.include? opt
        end
	self.respond_to_all_events = true
        yield self if block_given?
      end

      def run(secs)
        start_widgets
        stdout_attach secs
      end

      def stop
	stop_widgets
	stdout_detach
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
	@stdout_loop_flag = true
        begin
          @stream_out.write JSON.generate(@header) + "\n"
	  @stream_out.flush
          @stream_out.write "[" + "\n"
          @stream_out.flush
          @stream_out.write [].to_s + "\n"
	  @stream_out.flush
          while @stdout_loop_flag do
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

      def stdout_detach
	@stdout_loop_flag = false
      end

      private

      def read_event_loop
        loop do
          l = @stream_in.readline.chomp
          if md = l.match(/(\{.+\})/)
            begin
              @event = Event.new JSON.parse md[1]
              notify_event @event
            rescue
              nil
            end
          end
        end
      end

      def notify_event(ev)
	super ev
	notify_to_widgets ev
      end

      def notify_to_widgets(ev)
	widgets.map { |w| w.notify_event ev }
      end

    end

    module Widgets
    end

    require 'i3rb/i3bar/widgets/basic_widgets'

    def self.get_instance(stream_in = nil, stream_out = nil, options = {})
      stream_in ||= $stdin
      stream_out ||= $stdout
      init_proc = Proc.new if block_given?
      Instance.new stream_in, stream_out, options, &init_proc
    end

  end
end
