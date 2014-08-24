require File.dirname(__FILE__) + '/../test_helper'

class PublisherUserTest < Test::Unit::TestCase
  fixtures :publisher_users

  # Replace this with your real tests.
  def test_truth
    assert_kind_of PublisherUser, publisher_users(:first)
  end
end
