module I3
  module Bar
    module EventHandler

      class Event
	PROPERTIES = [ :button, :x, :y, :instance, :name ]
	PROPERTIES.each do |prop|
	  attr_accessor prop
	end
	def initialize(hash)
	  PROPERTIES.each do |prop|
	    self.send "#{prop}=", hash[prop.to_s]
	  end
	end
	def is_valid?
	  !PROPERTIES.map {|p| self.send p }.include? nil
	end
	def to_s
	  "Event from #{instance}: button #{button}"
	end
      end

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
        return nil unless is_receiver?(ev) || respond_to_all_events?
        execute_callbacks ev
      end

      def execute_callbacks(ev)
        event_callbacks.map do |cb|
          cb.call self, ev
        end
      end

      def reset_callbacks
        event_callbacks.clear
      end

      def is_receiver?(ev)
        ev.instance == instance
      end

      attr_accessor :respond_to_all_events
      alias :respond_to_all_events? :respond_to_all_events

    end
  end
end
