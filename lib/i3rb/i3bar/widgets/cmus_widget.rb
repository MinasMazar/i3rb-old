# coding: utf-8
module I3
  module Bar
    module Widgets

      class CMUS < Widget
        def self.get_instance
          new 5
        end
        def initialize(timeout)
          super :cmus, timeout do |w|
	          cmus = `cmus-remote --query`
	          if md = cmus.match(/status\s(\w+)/)
             status = md[1]
	          end
	          if md = cmus.match(/tag title\s(.+)/)
             title = md[1]
	          end
	          if md = cmus.match(/tag artist\s(.+)/)
             artist = md[1]
	          end
	          if title.nil? || artist.nil? || title.empty? || artist.empty?
             track_desc = "No Tags :("
	          else
             track_desc = "#{title} - #{artist}"
	          end
	          if status == "playing"
             "#{track_desc} |>"
	          elsif status == "paused"
             "#{track_desc} ||"
	          elsif status == "stopped"
             "No Playing"
	          else
             w.timeout = 60
             "CMUS inactive"
	          end
          end

          add_event_callback do |w,e|
	          if e.button == 1
             system "cmus-remote", "--pause"
	          elsif e.button == 3
             system "cmus-remote", "--next"
	          end
          end
        end
      end

    end
  end
end
