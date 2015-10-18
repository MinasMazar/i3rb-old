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
    i3bar.add_widget I3::Bar::Widgets::HOSTNAME
    i3bar.add_widgets [ I3::Bar::Widgets::CALENDAR, I3::Bar::Widgets::WIFI ]
    i3bar.add_widget I3::Bar::Widgets::TEMPERATURE
    i3bar.add_widget I3::Bar::Widgets::TEMPERATURE
    i3bar.add_widget "This is not a Widget instance"
    assert_equal 4, i3bar.widgets.size
  end

  def test_widgets_modular_init
    i3bar = I3::Bar.get_instance do |b|
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
    i3bar.add_widget I3::Bar::Widgets::BASIC
    Thread.new { sleep 2; i3bar.stop }
    i3bar.run 1
  end

  def test_single_widget_once
    bar = I3::Bar.get_instance
    widget = I3::Bar::Widgets::TEMPERATURE
    widget.timeout = 0
    pre_add_id = widget.__id__
    bar.add_widget widget
    widget = bar.widget :temp
    post_add_id = widget.__id__
    bar.start_widgets
    widget.instance_variable_get(:@run_th).join
    assert_equal pre_add_id, post_add_id
  end

  def test_i3bar_events
    stdin = File.new(File.expand_path("../../tmp/STDIN", __FILE__))
    widget = I3::Bar::Widgets::CALENDAR
    widget.add_event_callback do |w, e|
      assert_kind_of I3::Bar::Widget, w
      assert_kind_of I3::Bar::EventHandler::Event, e
      assert e.button == 3, "Event is #{e.inspect}"
      @widget_callback_executed = true
    end
    fake_ev = I3::Bar::EventHandler::Event.new "name" => "calendar", "instance" => widget.instance, "button" => 3, "x" => 1297, "y" => 9
    assert fake_ev.is_valid?
    bar = I3::Bar.get_instance stdin, $stdout do |b|
      b.add_event_callback do |w, e|
	assert_kind_of I3::Bar::Instance, w
	assert_kind_of I3::Bar::EventHandler::Event, e
	assert e.button == 3, "Event is #{e.inspect}"
	@bar_callback_executed = true
      end
      b.add_widget widget
    end

    bar.start_events_capturing
    sleep 0.5
    bar.send :notify_event, fake_ev

    assert @widget_callback_executed, "Widget callback not executed"
    assert @bar_callback_executed, "Bar callback not executed"
  end

  def test_procs_for_debugging_purposes
    I3::Bar::Widgets::BASIC.each do |w|
      p = w.instance_variable_get "@block"
      assert_kind_of String, p.call(w)
    end
  end

end
