module I3
  module DMenu

    DMENU_BIN = "dmenu -b "

    def self.get_instance
      Object.new.extend DMenu
    end

    attr_accessor :entries
    def entries
      @entries ||= []
    end

    def get_string
      @last_string = ` echo \"#{entries.join " "}\" | #{DMENU_BIN} `
    end

    def get_array
      get_string.split(" ")
    end

    def dmenu
      @dmenu ||= DMenu.get_instance
    end

  end
end
