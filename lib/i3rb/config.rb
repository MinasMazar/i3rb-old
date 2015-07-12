module I3
  class Config

    module Shortcuts
      def bindsym(sym, action)
        shortcuts["#{sym}"] = action
      end
      def shortcuts
        @shortcuts ||= {}
      end
    end

    class Mode
      include Shortcuts
    end

    attr_accessor :path, :floating_modifier, :mod_key

    def self.from_file(pathname)
      f = File.readlines pathname
      cur_mode = :default
      c = new
      f.each do |l|
        if md = l.match(/floating_modifier (.+?)/)
          c.floating_modifier = md[0]
        end
        if md = l.match(/mode"(.+?)"/)
          cur_mode = md[1].to_sym
        end
        if md = l.match(/bindsym ([\w|\+]+)\s(.+?)/)
          c.modes[cur_mode].bindsym md[1], md[2]
        end
      end
      c
    end

    def initialize
      @modes = {}
      add_mode :default
    end

    def to_s
      s = ""
      s += "#{ "floating_modifier #{floating_modifier}" if floating_modifier }\n\n"
      modes.each do |name, mode|
        s += "mode \"#{name}\" {\n"
        mode.shortcuts.each do |sym, action|
          s += "bindsym #{sym} #{action}\n"
        end
        s += "}\n\n"
      end
      
      s += "\n"
      s
    end

    attr_reader :modes, :cur_mode

    def add_mode(name)
      @modes[name] = Mode.new
      if block_given?
        yield @modes[name]
      end
    end

    def default_mode
      @modes[:default]
    end

  end
end
