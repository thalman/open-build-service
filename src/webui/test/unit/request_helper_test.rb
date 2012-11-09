require File.expand_path(File.dirname(__FILE__) + "/..") + "/test_helper"

include RequestHelper
include ActionView::Helpers::TagHelper

require 'xmlhash'

class RequestHelperTest < ActiveSupport::TestCase

  def test_request_state_icon
    assert_equal 'flag_green', map_request_state_to_flag('new')

    assert_equal '', map_request_state_to_flag(nil)
  end
end

