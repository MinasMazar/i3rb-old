require 'i3rb'
require 'i3ipc'
require 'benchmark'

i3rb_sys = Object.new.extend I3::API
i3rb_ipc = Object.new.extend I3::API
class << i3rb_ipc
  def i3send(msg)
    i3ipc msg
  end
end
i3ipc = I3Ipc::Connection.new

Benchmark.bm do |x|
  x.report("i3rb-system-call") { i3rb_sys.goto_workspace 'bench1' }
  x.report("i3rb-ipc") { i3rb_ipc.goto_workspace 'bench2' }
  x.report("i3ipc") { i3ipc.command 'workspace bench3' }
end
i3rb_ipc.connection.disconnect
i3ipc.disconnect
