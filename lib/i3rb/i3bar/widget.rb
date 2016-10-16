module I3
  module Bar
    class Widget

      LOG_FILE = "~/.i3/widgets.log"

      include EventHandler

      attr_accessor :name, :text, :short_text, :timeout, :block
      attr_accessor :pos, :color

      def initialize(name, timeout = 0, options = {}, &proc)
        @name = name
        @text = name
        @short_text = text
        @active = true
        @options = options
        @color = @options[:color] if @options[:color]
        @pos = @options[:pos] if @options[:pos]
        if @options[:events]
          @options[:events] = [ @options[:events] ] unless @options[:events].is_a? Array
          @options[:events].each do |ev|
            add_event_callback ev
          end
        end
        @timeout = timeout.to_i.abs
        @suspended_events = false
        @block = proc || lambda {}
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
            block_eval!
            break if @timeout <= 0
            sleep @timeout.to_i
          end
        end
      end

      def suspend_events(secs = 0)
        @suspended_events = true
        if secs > 0
          @suspend_th = Thread.new do
            sleep secs
            @suspended_events = false
          end
        end
      end

      def block_eval!
	      ret = @block.call self
        if ret.kind_of? String
          self.text = ret
        elsif ret.kind_of?(Array) && ret.size == 2
          self.text = ret[0]
          self.short_text = ret[1]
        end
      end

      alias :refresh! :block_eval!

      def notify_event(ev)
        return nil if @suspended_events
	      super ev
	      block_eval!
      end

      def to_i3bar_protocol
        h = {
          "full_text" => text
        }
        h.merge! "short_text" => short_text
        h.merge! "color" => self.color if @color
        h.merge! "name" => name
        h.merge! "instance" => instance
        h
      end

      def ==(w)
	      self.instance == w.instance
      end

      def to_s
	      "#{instance}"
      end

      def self.system_exec(*cmdline)
        begin
          $logger.debug "Widget::system_exec(\"#{cmdline.join(' ')} >> #{LOG_FILE}\""
          system "#{cmdline.join(' ')} >> #{LOG_FILE}"
        rescue Exception => e
          $logger.debug"Exception catched: #{e}"
        end
      end
      def system_exec(*cmdline)
        Widget.system_exec *cmdline
      end
    end
  end
end
