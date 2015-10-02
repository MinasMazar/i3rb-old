require 'i3ipc'

module I3
  module API

    class CommandError < StandardError; end
    module Workspace; end

    [ :get_workspaces, :get_outputs, :get_tree, :get_marks, :get_bar_config, :get_version ].each do |meth|
      define_method meth do
        system_i3msg "-t #{meth}"
      end
    end
  
    def current_workspace
      ws = get_workspaces.find {|w| w["focused"]}
      ws.extend Workspace
    end

    def current_workspaces
      wss = get_outputs.select {|o| o["current_workspace"] != nil }
      wss.map! {|ws| ws.extend Workspace }
    end

    def get_active_outputs
      get_outputs.select {|o| o["active"] == true }
    end

    def goto_workspace(ws = :back_and_forth)
      if ws.to_s.match /^\d+:?/
	i3send "workspace number #{ws}"
      else
	i3send "workspace #{ws}"
      end
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

    [ :restart, :reload, :quit, :kill ].each do |meth|
      define_method meth do
        i3send "#{meth}"
      end
    end

    def buffer
      @buffer ||= []
    end

    def i3send(msg)
      ret = exec_i3send msg
      ret
    end

    attr_reader :connection

    protected

    def system_i3msg(*msg)
      msg = msg.join(", ")
      ret = JSON.parse `i3-msg #{msg}`
      $logger.debug "system:i3-msg < #{msg} > => #{ret}" if $debug
      return yield(ret) if block_given?
      raise CommandError.new if ret && ret.any? && ret[0]["success"] == false
      ret
    end

    def system_i3pipe(*msg)
      msg = msg.join(", ")
      command = [ "i3-msg" ] + msg
      pipe = IO.popen(command, "w+")
      ret = pipe.read
      $logger.debug "system:i3pipe < #{msg} > => #{ret}" if $debug 
      raise CommandError.new ret[0]["error"] if ret && ret.any? && ret[0]["success"] == false
      pipe.close
      JSON.parse ret.chomp
    end
      
    def connection
      @connection ||= reset_connection!
    end

    def reset_connection!
      @connection = I3Ipc::Connection.new
    end

    def i3ipc(*msg)
      msg = msg.join(", ")
      ret = connection.command msg
      $logger.debug "system:i3-ipc < #{msg} > => #{ret}" if $debug
      return yield(ret) if block_given?
      if ret[0].success?
        ret[0].to_h
      else
        raise CommandError.new ret[0]["error"]
      end
    end

    alias :exec_i3send :system_i3msg

  end
end
