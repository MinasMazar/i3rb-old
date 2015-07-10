module I3
  module Bar

    class Widget

      attr_reader :name, :options
      attr_accessor :timeout, :proc

      def self.from_desc(desc)
        new desc[:name], desc[:timeout], desc[:options], &desc[:proc]
      end

      def initialize(name, timeout, options = {}, &proc)
        @name = name
        @text = "..."
        @active = true
        @options = options
        self.timeout = timeout
        self.set_proc(&proc)
      end

      def pos
        @options[:pos] || -1
      end

      def active?
        @options[:active] != false
      end

      def set_proc(&proc)
        @proc = proc
      end

      def stop
        @run_th && @run_th.kill
      end

      def run
        @run_th = Thread.new do
          loop do
            #@text = binding.call @proc
            @text = self.proc.call
            break if @timeout.to_i <= 0
            sleep @timeout.to_i
          end
        end
      end

      def eval
        active? ? @text : ''
      end

    end

    module Methods

      def widgets
        @widgets ||= []
      end

      def add_widget(widget)
        if widget.is_a? Hash
          widget = Widget.from_desc widget
        end
        self.widgets << widget if widget.kind_of? Widget
      end

      def to_s
        widgets.map(&:eval).map(&:chomp).join(" | ").to_s
      end
    
      def to_stdout
        $stdout.write to_s + "\n"
        $stdout.flush\
      end
    
      def stdout_attach(sec)
        loop do
          to_stdout
          sleep sec
        end
      end
    
      def run_widgets
        widgets.each { |w| w.run if w.active? }
      end

    end

    class Instance
      include Methods
    end

    require 'i3rb/i3-bar-widgets/hostname'

    def self.get_instance
      Instance.new
    end

  end
end
