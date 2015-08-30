require 'minitest_helper'

class TestBar < Minitest::Test

  @@i3bar = I3::Bar.get_instance

  def test_I3BAR_launch_bar
    @@i3bar.add_widget I3::Bar::Widgets::HOSTNAME
    @@i3bar.run 1
  end

end