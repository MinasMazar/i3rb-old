require 'minitest_helper'
require 'benchmark'

class TestDMenu < Minitest::Test

  def test_dmenu_init_with_prompt_and_lines_as_arguments
    dmenu_instance = I3::DMenu.new :prompt => "Prompt", :lines => 3
    assert_equal "Prompt", dmenu_instance.prompt
    assert_equal 3, dmenu_instance.lines
  end

  def test_dmenu_init_with_prompt_and_lines_as_block
    dmenu_instance = I3::DMenu.new do
      set_prompt "Prompt"
      set_lines 3
    end
    assert_equal 3, dmenu_instance.get_lines
  end

  def test_dmenu_get_string_with_items
    dmenu_instance = I3::DMenu.new :prompt => "Prompt" do
      set_lines 4
      set_items %w{ item1 item2 item3 }
    end
    assert_kind_of String, dmenu_instance.get_string
  end

end
