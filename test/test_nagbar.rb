require 'minitest_helper'

class TestNagbar < Minitest::Test

  def test_initialize
    nagbar = I3::Nagbar.instance
    assert_kind_of I3::Nagbar::Instance, nagbar
  end

  def test_start
    nagbar = I3::Nagbar.instance
    nagbar.prompt = "Common system commands"
    nagbar.add_button "TOP", "top"
    nagbar.add_button "CLOSE WIN", "i3-msg kill"
    assert nagbar.start
  end
    
end