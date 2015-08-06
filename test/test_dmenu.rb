require 'minitest_helper'
require 'benchmark'

class TestDMenu < Minitest::Test

  @@dmenu = I3::DMenu.get_instance
  @@dmenu.lines = 3
  @@dmenu.items = [ "AB", "NORMAL", "BRAIN"]

  def _test_dmenu_run__pipe_impl
    ret =  @@dmenu.run__pipe_impl
    assert_instance_of I3::DMenu::Item, ret
  end

  def _test_dmenu_run__sys_call_impl
    ret =  @@dmenu.run__sys_call_impl
    assert_instance_of I3::DMenu::Item, ret
  end

  def test_dmenu_get_string
    ret =  @@dmenu.get_string
    assert_instance_of String, ret
  end

  def test_dmenu_get_array
    ret =  @@dmenu.get_array
    assert_instance_of Array, ret
  end

  def test_benchmark
    Benchmark.bm do |bm|
      bm.report "syscall" do
        @@dmenu.run__sys_call_impl
      end
      bm.report "pipe" do
        @@dmenu.run__pipe_impl
      end
    end
  end

end