require 'minitest_helper'

class TestConfig < Minitest::Test

  @@api_driver = Object.new.extend I3::API

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

  def test_build_config_from_file
    nc = I3::Config.from_file File.expand_path "../../tmp/config", __FILE__
    puts nc.to_s
  end

end