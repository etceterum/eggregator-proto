require File.dirname(__FILE__) + '/../test_helper'
require 'story_controller'

# Re-raise errors caught by the controller.
class StoryController; def rescue_action(e) raise e end; end

class StoryControllerTest < Test::Unit::TestCase
  def setup
    @controller = StoryController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
