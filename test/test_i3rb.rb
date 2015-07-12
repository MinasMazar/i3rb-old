require 'minitest_helper'
require 'pry'

class TestI3rb < Minitest::Test

  @@api_driver = Object.new.extend I3::API
  @@i3bar = I3::Bar.get_instance

  def test_that_it_has_a_version_number
    refute_nil ::I3::VERSION
  end

  def test_I3API_methods
    [ :restart, :quit, :reload, :goto_workspace ].each do |meth|
      assert_respond_to @@api_driver, meth
    end
    assert_kind_of Hash, @@api_driver.current_workspace
  end

  def test_launch_terminal
    @@api_driver.exec 'i3-sensible-terminal'
  end

  def untest_I3BAR_launch_bar
    @@i3bar.add_widget I3::Bar::BasicWidgets::Hostname
    @@i3bar.run_widgets
    sleep 0.8
    @@i3bar.to_stdout
  end

  def test_generate_config_from_scratch
    nc = I3::Config.new
    nc.mod_key = 'Mod1'
    nc.floating_modifier = 'Mod1'
    nc.default_mode.bindsym 'mod+o', 'exec i3-sensible-terminal'
    assert_instance_of I3::Config::Mode, nc.default_mode
    nc.add_mode :launch do |m|
      m.bindsym "Mod1+3", "workspace 3"
    end
    puts nc.to_s
    puts nc.inspect
  end

  def untest_build_config_from_file
    nc = I3::Config.from_file File.expand_path "../../tmp/config", __FILE__
    puts nc.to_s
  end

end
