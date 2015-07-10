require 'minitest_helper'
require 'pry'

class TestI3rb < Minitest::Test

  @@api_driver = Object.new.extend I3::API
  @@i3bar = I3::Bar.get_instance

  def test_that_it_has_a_version_number
    refute_nil ::I3rb::VERSION
  end

  def test_I3API_launch_terminal
    assert_kind_of Hash, @@api_driver.current_workspace
  end

  def test_I3BAR_launch_bar
    @@i3bar.add_widget I3::Bar::BasicWidgets::Hostname
    @@i3bar.run_widgets
    sleep 0.8
    @@i3bar.to_stdout
  end

end
