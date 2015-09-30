require 'minitest_helper'

class TestBar < Minitest::Test

  def test_i3bar_setup
    i3bar = I3::Bar.get_instance
    assert_kind_of Array, i3bar.widgets
  end

  def test_i3bar_setup_with_options
    i3bar = I3::Bar.get_instance nil, nil, "click_events" => false
    assert i3bar.options.include? "click_events"
    refute i3bar.instance_variable_get("@header")["click_events"], "Options assignment error."
  end

  def test_widgets
    i3bar = I3::Bar.get_instance
    i3bar.add_widget I3::Bar::Widgets::HOSTNAME
    i3bar.add_widgets [ I3::Bar::Widgets::CALENDAR, I3::Bar::Widgets::WIFI ]
    i3bar.add_widget I3::Bar::Widgets::TEMPERATURE
    i3bar.add_widget "This is not a Widget instance"
    assert_equal 4, i3bar.widgets.size
  end

  def untest_i3bar_running
    i3bar = I3::Bar.get_instance
    i3bar.add_widget I3::Bar::Widgets::BASIC
    i3bar.run 1
  end

  def test_single_widget_once
    bar = I3::Bar.get_instance
    widget = I3::Bar::Widgets::TEMPERATURE
    widget.timeout = 0
    pre_add_id = widget.__id__
    bar.add_widget widget
    widget = bar.widget "temp"
    post_add_id = widget.__id__
    bar.start_widgets
    widget.instance_variable_get(:@run_th).join
    assert_equal pre_add_id, post_add_id
  end

  def test_i3bar_events
    widget = I3::Bar::Widgets::CALENDAR
    fake_ev = [
      {"name" => "calendar", "instance" => widget.instance, "button" => 3, "x" => 1297, "y" => 9}
    ]
    File.write File.expand_path("../../tmp/STDIN", __FILE__), JSON.generate(fake_ev)

    fin = File.new(File.expand_path("../../tmp/STDIN", __FILE__))
    fout = File.new(File.expand_path("../../tmp/STDOUT", __FILE__), "w")
    bar = I3::Bar.get_instance fin, fout

    widget.add_event_callback do |w, e|
      assert_kind_of I3::Bar::Widget, w
      assert_kind_of Hash, e
      @callback_executed = true
    end

    bar.add_widget widget

    bar.start_events_capturing
    sleep 0.5

    ev = bar.event
    assert_kind_of Hash, ev

    assert ev["button"] == 3, "Event is #{ev.inspect}"
    assert @callback_executed, "Event callback not executed"

    fin.close
    fout.close
  end

end
