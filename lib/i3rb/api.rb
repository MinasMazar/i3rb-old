require 'i3ipc'

module I3
  module API

    module Workspace; end

    [ :get_workspaces, :get_outputs, :get_tree, :get_marks, :get_bar_config, :get_version ].each do |meth|
      define_method meth do
        system_i3msg "-t #{meth}"
      end
    end
  
    def current_workspace
      ws = get_workspaces.find {|w| w["focused"]}
      ws.extend Workspace if ws
    end

    def current_workspaces
      wss = get_outputs.select {|o| o["current_workspace"] != nil }
      wss.map! {|ws| ws.extend Workspace } if wss && wss.any?
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

    def exec(*cmd)
      i3send "exec \"#{cmd.join(" ")}\""
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
      ret = exec_i3send buffer.join(", ") if buffer.size > 0
      @buffer = []
      ret
    end

    attr_reader :connection

    def connection
      @connection ||= reset_connection!
    end

    def reset_connection!
      @connection = I3Ipc::Connection.new
    end

    protected

    def system_i3msg(*msg)
      msg = msg.join(", ")
      $logger.debug "system:i3-msg < #{msg} >" if $debug
      ret = JSON.parse `i3-msg #{msg}`
      $logger.debug "=> #{ret}" if $debug
      return yield(ret) if block_given?
      ret
    end

    def system_i3pipe(*msg)
      msg = msg.join(", ")
      msg = msg.split(" ")
      command = [ "i3-msg", *msg ]
      pipe = IO.popen(command, "w+")
      ret = pipe.read
      pipe.close
      JSON.parse ret.chomp
    end
      
    def i3ipc(*msg)
      msg = msg.join(", ")
      $logger.debug "i3-ipc < #{msg} >" if $debug
      ret = connection.command msg
      $logger.debug "=> #{ret}" if $debug
      return yield(ret) if block_given?
      if ret[0].success?
        ret[0].to_h
      else
        ret[0]
      end
    end

    alias :exec_i3send :system_i3pipe

  end
end