require 'i3ipc'

module I3
  module API
  
    [ :get_workspaces, :get_outputs, :get_tree, :get_marks, :get_bar_config, :get_version ].each do |meth|
      define_method meth do
        i3send "-t #{meth}"
      end
    end
  
    def current_workspace
      get_workspaces.find {|w| w["focused"] == true }
    end

    def current_workspaces
      get_outputs.select {|o| o["current_workspace"] != nil }
    end

    def get_active_outputs
      get_outputs.select {|o| o["active"] == true }
    end

    def goto_workspace(ws = :back_and_forth)
      ws = 'back_and_forth' if ws == :back_and_forth
      i3send "workspace #{ws}"
    end

    def move_to_workspace(ws)
      i3send "move container to workspace #{ws}"
    end

    def goto_output(out)
      i3send "focus output #{out}"
    end

    def exec(cmd)
      i3send "exec \"#{cmd}\""
    end

    [ :restart, :reload, :quit ].each do |meth|
      define_method meth do
        i3send "#{meth}"
      end
    end

    def buffer
      @buffer ||= []
    end

    def i3send(msg)
      self.buffer << msg
      flush! if self.buffer.size >= 1
    end

    def flush!
      ret = system_i3msg buffer.join(", ")
      @buffer = []
      ret
    end

    attr_reader :connection

    def connection
      @connection ||= I3Ipc::Connection.new
    end

    protected
  
    def system_i3msg(*msg)
      msg = msg.join(", ")
      ret = JSON.parse `i3-msg #{msg}`
      $logger.debug "system:i3-msg < #{msg} > => #{ret}" if $debug
      return yield(ret) if block_given?
      ret
    end

    def i3ipc(*msg)
      msg = msg.join(", ")
      ret = connection.command msg
      $logger.debug "i3-ipc < #{msg} > => #{ret}" if $debug
      return yield(ret) if block_given?
      ret 
    end

  end
end