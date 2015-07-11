require 'minitest_helper'
require 'pry'

class TestI3rb < Minitest::Test

  @@api_driver = Object.new.extend I3::API
  @@i3bar = I3::Bar.get_instance

  def test_that_it_has_a_version_number
    refute_nil ::I3::VERSION
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

  def test_shortcuts
    nc = I3::Config.new
    nc.add_shortcut 'mod+o', 'exec i3-sensible-terminal'
    puts nc.to_s
  end

end
