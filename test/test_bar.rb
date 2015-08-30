require 'minitest_helper'

class TestBar < Minitest::Test

  def test_i3bar_setup
    i3bar = I3::Bar.get_instance
    i3bar.add_widget I3::Bar::Widgets::HOSTNAME
    i3bar.add_widgets [ I3::Bar::Widgets::CALENDAR, I3::Bar::Widgets::WIFI ]
    i3bar.add_widget I3::Bar::Widgets::TEMPERATURE
    assert_kind_of Array, i3bar.widgets
  end

  def test_i3bar_running
    i3bar = I3::Bar.get_instance
    i3bar.add_widget I3::Bar::Widgets::BASIC
    i3bar.run 1
  end

  def test_single_widget_once
    bar = I3::Bar.get_instance
    widget = I3::Bar::Widgets::TEMPERATURE
    widget.timeout = 0
    bar.add_widget widget
    bar.start_widgets
    widget.instance_variable_get(:@run_th).join
  end

end