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
        return nil unless is_receiver?(ev) || respond_to_all_events?
        execute_callbacks ev
      end
      
      def execute_callbacks(ev)
        event_callbacks.map do |cb|
          cb.call self, ev
        end
      end
      
      def is_receiver?(ev)
        ev["instance"] == instance
      end
      
      attr_accessor :respond_to_all_events
      alias :respond_to_all_events? :respond_to_all_events
  
    end
  end
end
