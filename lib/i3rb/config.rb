module I3
  class Config

    module Bindsyms
      attr_reader :bindsyms
      def bindsym(sym, action)
        @bindsyms["#{sym}"] = action
      end
    end

    class Mode
      include Bindsyms
      def initialize
        @bindsyms = {}
      end
    end

    attr_accessor :path, :floating_modifier, :mod_key

    def self.backup_config
      orig_config = "~/.i3/config"
      orig_config = File.read orig_config
      bkp_config = "~/.i3/config.bkp"
      File.write bkp_config, orig_config
    end

    def self.write_i3rb_config(config)
      orig_config = "~/.i3/config"
      File.write orig_config, config.to_s
    end

    def self.apply_i3rb_config(config)
      backup_config
      write_i3rb_config config
    end

    def self.from_file(pathname)
      f = File.readlines pathname
      c = new
      cur_mode = :default
      f.each do |l|
        if md = l.match(/floating_modifier (.+?)/)
          c.floating_modifier = md[0]
        end
        if md = l.match(/mode\s+"(.+?)"/)
          cur_mode = md[1].to_sym
        end
        if md = l.match(/\}/)
          cur_mode = :default
        end
        if md = l.match(/bindsym ([\w|\d|\+]+)\s(.+)/)
          c.get_mode(cur_mode).bindsym md[1], md[2]
        end
      end
      c
    end

    def initialize
      @modes = { :default => Mode.new }
    end

    def to_s
      s = []
      s << "floating_modifier #{floating_modifier}" if floating_modifier
      default_mode.bindsyms.each do |sym, action|
        s << "bindsym #{sym} #{action}"
      end
      modes_without_default.each do |name, mode|
        s << "mode \"#{name}\" {"
        mode.bindsyms.each do |sym, action|
          s << "bindsym #{sym} #{action}"
        end
        s << "}\n"
      end
      s.join "\n"
    end

    attr_reader :modes, :cur_mode

    def get_mode(name)
      @modes[name] ||= Mode.new
      if block_given?
        yield @modes[name]
      end
      @modes[name]
    end

    alias :add_mode :get_mode

    def default_mode
      @modes[:default]
    end

    def modes_without_default
      @modes.select {|k,v| k != :default }
    end

  end
end
