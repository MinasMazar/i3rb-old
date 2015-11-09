require 'minitest_helper'
require 'pry'

class TestCLI < Minitest::Test

  @@driver = I3::CLI.get_instance

  def test_goto_workspace_69
    @@driver.run ["goto_workspace", "69"]
  end

  def test_exec_terminal_app
    @@driver.run ["exec", "i3-sensible-terminal", "-e", "top" ]
  end

  def test_goto_workspace_stdin
    puts "\nInsert workspace to switch to: "
    @@driver.run ["goto_workspace", "_stdin_"]
  end

  def test_goto_workspace_dmenu
    @@driver.run ["goto_workspace", "_dmenu_"]
  end

  def test_goto_workspace_dmenu_with_items
    @@driver.run ["goto_workspace", "_dmenu_ws_"]
  end

end
