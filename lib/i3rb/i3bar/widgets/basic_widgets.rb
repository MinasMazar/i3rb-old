 module I3
  module Bar
    module Widgets

      HOSTNAME = Widget.new :hostname, 0 do
        [ `whoami`.chomp, '@',  `hostname`.chomp ].join
      end

      CALENDAR = Widget.new :calendar, 1 do
        Time.new.strftime('%d-%m-%Y %H:%M:%S')
      end

      WIFI = Widget.new :wifi, 10 do |w|
        iwc_out = `iwconfig 2>/dev/null`.gsub("\n", " ")
        out = "WiFi: "
        if md = iwc_out.match(/ESSID:"(.+)"/)
          w.color = "#00FF00"
          out += "#{md[1]} "
          if md = iwc_out.match(/Link Quality=(\d+)\/(\d+)/)
            signal, range = md[1].to_i, md[2].to_i
            signal_percent = signal * 100 / range
            out += " (#{signal_percent}%) "
          end
        else
          out += "down "
          w.color = "#FF0000"
        end
        out
      end

      TEMPERATURE = Widget.new :temp, 15 do |w|
        w.kill unless `sensors`.gsub("\n", " ").match(/acpitz/)
        out = "Temp: "
        if md = `sensors`.gsub("\n", " ").match(/temp1:\s+(\S+)°C\s+\(crit\s+=\s+(\S+)°C\)/)
          temp, crit = md[1].to_f, md[2].to_f
          out += "#{temp}"
          w.color = "#FF0000" if temp >= crit
          w.color = "#FFFF00" if temp < crit - 8
          w.color = "#00FF00" if temp < crit - 16
        else
          out += "NONE"
          w.color = "#FF0000"
        end
        out
      end

      BATTERY = Widget.new :battery, 60 do |w|
	acpi_res = `acpi -b`
	if md = acpi_res.match(/Battery\s(\d+):\s(\w+),\s(\d+)%/)
	  status = md[2]
	  charging_percentage = md[3].to_i
	  if  charging_percentage > 70
	    w.color = "#00FF00"
	  elsif charging_percentage > 30
	    w.color = "#00FFFF"
	  else
	    w.color = "#FF0000"
	  end
	  "BATTERY: #{charging_percentage}% #{status}"
	else
	  w.kill
	  false
	end
      end

      CMUS = Widget.new :cmus, 5 do |w|
	w.timeout = 5
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
	  "🎜 #{track_desc} 🎜"
	elsif status == "paused"
	  "🎜 #{track_desc} (pause) 🎜"
	elsif status == "stopped"
	  "🎜 No Playing 🎜"
	else
	  w.timeout = 60 
	  "🎜 CMUS inactive 🎜"
	end
      end

      CMUS.add_event_callback do |w,e|
	if e.button == 1
	  system "cmus-remote", "--pause"
	elsif e.button == 3
	  system "cmus-remote", "--next"
	end
      end

      BASIC = [ HOSTNAME, CMUS, WIFI, BATTERY, TEMPERATURE, CALENDAR ]

      BASIC.each do |widget|
	define_method widget.name do
	  w = widget widget.name
	  return w if w
	  add_widget widget
	  return widget
	end
      end

      def add_basic_widgets
	add_widgets BASIC
      end

      def add_widget(widget)
        @widgets << widget
      end

      alias :add_widgets :add_widget

      def widget(w)
        widgets.find { |_w| _w.name == w }
      end

      def widgets
	@widgets.flatten!
	@widgets.reject! {|w| !w.kind_of? Widget }
	@widgets.sort_by! {|w| w.pos }
	@widgets.uniq!
	@widgets
      end

    end
  end
end