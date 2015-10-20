module I3  
  module Nagbar
  
    Button = Struct.new :title, :cmd
  
    attr_accessor :buttons, :font, :prompt

    class Instance
      include Nagbar
    end
    def self.instance
      nb = Instance.new
      nb.font = "-misc-fixed-medium-r-normal--13-120-75-75-C-70-iso10646-1"
      nb
    end

    def prompt
      @prompt ||= ".."
    end

    def buttons
      @buttons ||= []
    end

    def add_button(title, cmd)
      self.buttons << Button.new(title, cmd)
    end
    def start
      cmd_txt = "i3-nagbar -t warn -f #{@font} -m #{prompt} "
      self.buttons.each {|b| cmd_txt += " -b \"#{b.title}\" \"#{b.cmd};read\"" }
      Kernel.spawn cmd_txt
    end
  end
  
end
