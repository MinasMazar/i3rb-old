require 'minitest_helper'

class TestBar < Minitest::Test

  def test_setup
    i3bar = I3::Bar.get_instance
    assert_kind_of Array, i3bar.widgets
  end

  def test_setup_with_options
    i3bar = I3::Bar.get_instance nil, nil, "click_events" => false
    assert i3bar.options.include? "click_events"
    refute i3bar.instance_variable_get("@header")["click_events"], "Options assignment error."
  end

  def test_widgets_pushing
    i3bar = I3::Bar.get_instance
    i3bar.add_widget I3::Bar::Widgets::Hostname.get_instance
    i3bar.add_widgets [ I3::Bar::Widgets::Calendar.get_instance, I3::Bar::Widgets::WiFi.get_instance ]
    i3bar.add_widget I3::Bar::Widgets::Temperature.get_instance
    i3bar.add_widget I3::Bar::Widgets::Temperature.get_instance
    assert_raises ArgumentError do
      i3bar.add_widget "This is not a Widget instance"
    end
    assert_equal 4, i3bar.widgets.size
  end

  def test_widgets_modular_init
    i3bar = I3::Bar.get_instance do |b|
      b.add_basic_widgets
      b.hostname.color = "#00FF00"
      b.hostname do
	"@darkstar"
      end
    end
    widget = i3bar.widget :hostname
    assert widget,  "The widget hostname should be present in the bar widgets list."
    assert i3bar.widget(:hostname).block, "The widget #{widget} should have a block."
    assert_equal "#00FF00",  i3bar.widget(:hostname).color
  end

  def test_add_basic_widgets
    i3bar = I3::Bar.get_instance do |bar|
      bar.add_basic_widgets
      bar.hostname.color = "#FFFFFF"
    end
    assert_equal i3bar.widgets.size, I3::Bar::Widgets::BASIC.size
  end

  def test_i3bar_running
    i3bar = I3::Bar.get_instance
    i3bar.add_basic_widgets
    Thread.new { sleep 2; i3bar.stop }
    i3bar.run 1
  end

  def test_single_widget_once
    bar = I3::Bar.get_instance
    widget = I3::Bar::Widgets::Temperature.get_instance
    widget.timeout = 0
    pre_add_id = widget.__id__
    bar.add_widget widget
    widget = bar.widget :temperature
    post_add_id = widget.__id__
    bar.start_widgets
    widget.instance_variable_get(:@run_th).join
    assert_equal pre_add_id, post_add_id
  end

  def test_i3bar_events
    @widget_callback_executed = false
    stdin = File.new(File.expand_path("../../tmp/STDIN", __FILE__))
    widget = I3::Bar::Widgets::Calendar.get_instance
    widget.add_event_callback do |w, e|
      assert_kind_of I3::Bar::Widget, w
      assert_kind_of I3::Bar::EventHandler::Event, e
      assert e.button == 3, "Expected button 3 but was given #{e.inspect}" if w.is_receiver?(e)
      @widget_callback_executed = true
    end
    mpd_widget = I3::Bar::Widgets::MPD.new("no-host", 10)
    mpd_widget.reset_callbacks
    mpd_widget.add_event_callback do |w,e|
      assert e.button == 1, "Expected button 1 but was given #{e.inspect}" if w.is_receiver?(e)
    end
    fake_ev = I3::Bar::EventHandler::Event.new "name" => "calendar", "instance" => widget.instance, "button" => 3, "x" => 1297, "y" => 9
    mpd_fake_ev = I3::Bar::EventHandler::Event.new "name" => "calendar", "instance" => mpd_widget.instance, "button" => 1, "x" => 1288, "y" => 11
    assert fake_ev.is_valid?
    bar = I3::Bar.get_instance stdin, $stdout do |b|
      b.add_event_callback do |w, e|
	assert_kind_of I3::Bar::Instance, w
	assert_kind_of I3::Bar::EventHandler::Event, e
	assert e.button == 2, "Expected button 2 but was given #{e.inspect}" if w.is_receiver?(e)
	@bar_callback_executed = true
      end
      b.add_widget widget
      b.add_widget mpd_widget
    end

    bar.start_events_capturing
    sleep 0.5
    bar.send :notify_event, fake_ev
    bar.send :notify_event, mpd_fake_ev

    assert @widget_callback_executed, "Widget callback not executed"
    assert @bar_callback_executed, "Bar callback not executed"
  end

  def test_suspend_widget
    @suspend_widget_received_event = false
    widget = I3::Bar::Widget.new :suspend_widget, 5 do
    end
    widget.add_event_callback do |w, e|
      @suspend_widget_received_event = true
    end
    fake_ev = I3::Bar::EventHandler::Event.new "name" => "suspend_widget", "instance" => widget.instance, "button" => 3, "x" => 1297, "y" => 9
    widget.notify_event fake_ev
    assert @suspend_widget_received_event
    @suspend_widget_received_event = false
    widget.suspend_events 0.3
    widget.notify_event fake_ev
    refute @suspend_widget_received_event
    sleep 1
    widget.notify_event fake_ev
    assert @suspend_widget_received_event
  end

  def test_procs_for_debugging_purposes
    I3::Bar::Widgets::BASIC.each do |w|
      w = w.get_instance
      p = w.instance_variable_get "@block"
      assert_kind_of String, p.call(w)
    end
  end

end
