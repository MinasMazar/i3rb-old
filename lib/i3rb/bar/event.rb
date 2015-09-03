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
  end
end
