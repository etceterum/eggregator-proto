class PublisherTopic < ActiveRecord::Base
  belongs_to              :publisher
  has_and_belongs_to_many :stories
  #has_many                :user_topics
  has_and_belongs_to_many :journals
  
  #acts_as_nested_set
  acts_as_tree

  # custom finders
  #def find_for_user(user)
  #  self.find(
  #    :all,
  #    :joins => 
  #      'inner join user_topics on user_topics.publisher_topic_id = publisher_topics.id',
  #    :conditions => ['user_topics.user_id = ?', user.id],
  #    :include => [:parent]
  #  )
  #end
end

