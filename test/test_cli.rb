require 'minitest_helper'
require 'pry'

class TestCLI < Minitest::Test

  class CLIDriver
    include I3::CLI
  end

  @@driver = CLIDriver.new

  def test_goto_workspace_69
    @@driver.run ["goto_workspace", "69"]
  end

end
