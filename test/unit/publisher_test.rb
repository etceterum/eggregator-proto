require File.dirname(__FILE__) + '/../test_helper'

class PublisherTest < Test::Unit::TestCase
  fixtures :publishers

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Publisher, publishers(:first)
  end
end
