require 'minitest_helper'
require'benchmark'

class TestI3rb < Minitest::Test

  @@api_driver = Object.new.extend I3::API
  @@i3bar = I3::Bar.get_instance

  class << @@api_driver
    alias :exec_i3send :system_i3msg
  end

  def test_that_it_has_a_version_number
    refute_nil ::I3::VERSION
  end

  def test_I3API_methods
    [ :restart, :quit, :reload, :goto_workspace ].each do |meth|
      assert_respond_to @@api_driver, meth
    end
    assert_kind_of Array, @@api_driver.get_workspaces
    assert_kind_of Hash, @@api_driver.current_workspace
    assert_kind_of Array, @@api_driver.current_workspaces
  end

  def test_benchmark
    iterations = 22
    Benchmark.bm 30 do |bm|
      class << @@api_driver
        alias :exec_i3send :system_i3msg
      end
      bm.report('system_i3msg') do
        iterations.times { @@api_driver.goto_workspace }
      end
      class << @@api_driver
        alias :exec_i3send :system_i3msg
      end    
      bm.report('system_i3pipe') do
        iterations.times { @@api_driver.goto_workspace }
      end
      class << @@api_driver
        alias :exec_i3send :i3ipc
      end    
      bm.report('i3ipc') do
        iterations.times { @@api_driver.goto_workspace }
      end
    end
  end

  def test_launch_terminal
    @@api_driver.exec 'i3-sensible-terminal'
  end

end
