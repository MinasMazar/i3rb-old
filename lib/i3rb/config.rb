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
      c = new
      f.each do |l|
        if md = l .match(/floating_modifier (.+?)/)
          c.floating_modifier = md[0]
        end
        if md = l .match(/bindsym ([\w|\+]+)\s(.+?)/)
          c.add_shortcut md[0], md[1]
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
      default_mode.shortcuts.each do |sym, action|
        s += "bindsym #{sym} #{action}\n"
      end
      s += "\n"
      s
    end

    attr_reader :modes

    def add_mode(name)
      @modes[name] = Mode.new
      if block_given?
        yield @modes[name]
      end
    end

    def default_mode
      @modes[:default]
    end

    extend Forwardable
    def_delegator :default_mode, :bindsym

  end
end
