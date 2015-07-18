require 'minitest_helper'

class TestDMenu < Minitest::Test

  @@dmenu = I3::DMenu.get_instance
  @@dmenu.entries = [ "AB", "NORMAL"]

  def test_dmenu_get_string
    assert_instance_of String, @@dmenu.get_string
  end

  def test_dmenu_get_array
    assert_instance_of Array, @@dmenu.get_array
  end

  include I3::DMenu

  def test_dmenu_included_module
    assert_kind_of I3::DMenu, dmenu
    assert_respond_to dmenu, :get_string
  end

end