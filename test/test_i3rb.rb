require 'minitest_helper'

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

end
