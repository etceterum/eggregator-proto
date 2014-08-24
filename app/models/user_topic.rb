class UserTopic < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :publisher_topic
  belongs_to  :bottom_story, :foreign_key => 'bottom_story_id', :class_name => 'Story'
end
