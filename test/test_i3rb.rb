require 'minitest_helper'

class TestI3rb < Minitest::Test

  @@api_driver = Object.new.extend I3::API
  @@i3bar = Object.new.extend I3::Bar

  def test_that_it_has_a_version_number
    refute_nil ::I3rb::VERSION
  end

  def test_I3API_launch_terminal
    assert_kind_of Hash, @@api_driver.current_workspace
  end

  def test_I3BAR_launch_bar
    @@i3bar.to_stdout
  end

end
