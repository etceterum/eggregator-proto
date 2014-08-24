class Publisher < ActiveRecord::Base
  has_many    :topics, :class_name => 'PublisherTopic', :order => 'publisher_topics.name'
  has_many    :root_topics, :class_name => 'PublisherTopic', :conditions => 'publisher_topics.parent_id is null', :order => 'publisher_topics.name'
  has_many    :users, :class_name => 'PublisherUser'
  has_many    :stories
end

