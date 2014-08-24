require File.dirname(__FILE__) + '/../test_helper'

class PublisherTopicTest < Test::Unit::TestCase
  fixtures :publisher_topics

  # Replace this with your real tests.
  def test_truth
    assert_kind_of PublisherTopic, publisher_topics(:first)
  end
end
