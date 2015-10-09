require 'minitest_helper'
require 'benchmark'

class TestDMenu < Minitest::Test

  @@dmenu = I3::DMenu.get_instance
  @@dmenu.lines = 3
  @@dmenu.items = [ "AB", "NORMAL", "BRAIN"]

  def test_DMenu_get_instance_block_initialization
    dmenu = I3::DMenu.get_instance do
      set_prompt "Are you normal?"
      set_items [ "AB", "NORMAL", "BRAIN" ]
      set_lines 3
    end
    choice = dmenu.run
    assert_includes [ "AB", "NORMAL", "BRAIN" ], choice.value
  end

  def test_DMenu_get_choice
    choice = I3::DMenu.get_choice do
      set_prompt "Are you normal?"
      set_items [ "AB", "NORMAL", "BRAIN" ]
      set_lines 3
    end
    assert_includes [ "AB", "NORMAL", "BRAIN" ], choice
  end

  def test_dmenu_get_string
    ret =  @@dmenu.get_string
    assert_instance_of String, ret
  end

  def test_dmenu_get_array
    ret =  @@dmenu.get_array
    assert_instance_of Array, ret
  end

  def untest_benchmark
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
