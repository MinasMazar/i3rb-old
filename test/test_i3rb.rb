require 'minitest_helper'
require'benchmark'

class TestI3rb < Minitest::Test

  include I3::API
  @@i3bar = I3::Bar.get_instance

  def test_that_it_has_a_version_number
    refute_nil ::I3::VERSION
  end

  def test_API
    [ :restart, :quit, :reload, :goto_workspace ].each do |meth|
      assert_respond_to self, meth
    end
    assert_kind_of Array, get_workspaces
    assert_kind_of Hash, current_workspace
    assert_kind_of Array, current_workspaces
  end

  def test_switching_workspaces
    goto_workspace "sw1"
    assert_equal current_workspace["name"], "sw1"
    goto_workspace 55
    assert_equal "55", current_workspace["name"]
    assert_equal 55, current_workspace["num"]
  end

  def test_bad_API
    assert_raises do
      i3send "very invalid commmand"
    end
  end

  def test_benchmark
    iterations = 22
    Benchmark.bm 30 do |bm|
      class << self
        alias :exec_i3send :system_i3msg
      end
      bm.report('system_i3msg') do
        iterations.times { goto_workspace }
	test_bad_API
      end
      class << self
        alias :exec_i3send :system_i3msg
      end    
      bm.report('system_i3pipe') do
        iterations.times { goto_workspace }
	test_bad_API
      end
      class << self
        alias :exec_i3send :i3ipc
      end    
      bm.report('i3ipc') do
        iterations.times { goto_workspace }
	test_bad_API
      end
    end
  end

  def test_launch_terminal
    exec 'i3-sensible-terminal'
  end

end
