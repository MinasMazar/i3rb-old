module I3
  module Bar
    class Widget

      include EventHandler

      attr_accessor :name, :text, :timeout, :block
      attr_accessor :pos, :color

      def initialize(name, timeout = 0, options = {}, &proc)
        @name = name
        @text = name
        @active = true
        @options = options
        @color = @options[:color] if @options[:color]
        @pos = @options[:pos] if @options[:pos]
        @timeout = timeout.to_i.abs
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
  end
end
