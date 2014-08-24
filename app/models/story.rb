class Story < ActiveRecord::Base
  belongs_to              :publisher
  belongs_to              :publisher_user
  has_and_belongs_to_many :publisher_topics
  has_many                :users
  has_many                :pins, :class_name => 'StoryPin'

  def self.find_present_by_user_and_page(user, per_page = nil, page_number = nil)
    self.find(
      :all,
      :conditions => ['user.id = ?', user.id],
      :order => 'stories.id asc',
      :joins =>
        'inner join publisher_topics_stories as story_topic on stories.id = story_topic.story_id ' +
        'inner join publisher_topics as topic on topic.id = story_topic.publisher_topic_id ' +
        'inner join user_topics as user_topic on user_topic.publisher_topic_id = topic.id and stories.id >= user_topic.bottom_story_id ' +
        'inner join users as user on user.id = user_topic.user_id and stories.id <= user.top_story_id ' +
        'inner join publisher_topics as container on container.id = topic.parent_id',
      :include => [:publisher, :publisher_user, { :publisher_topics => :parent }],
      :limit => per_page,
      :offset => page_number && page_number*per_page
    )
  end

  def self.count_present_by_user(user)
    self.count_by_sql([
      'select count(*) from stories as story ' +
      'inner join publisher_topics_stories as story_topic on story.id = story_topic.story_id ' +
      'inner join publisher_topics as topic on topic.id = story_topic.publisher_topic_id ' +
      'inner join user_topics as user_topic on user_topic.publisher_topic_id = topic.id and story.id >= user_topic.bottom_story_id ' +
      'inner join users as user on user.id = user_topic.user_id and story.id <= user.top_story_id ' +
      "where user.id = ?", user.id
      ])
  end

  # FIXME topic_ids
  def self.count_future_by_user(user)
    self.count_by_sql([
      'select count(*) from stories as story ' +
      'inner join publisher_topics_stories as story_topic on story.id = story_topic.story_id ' +
      'inner join publisher_topics as topic on topic.id = story_topic.publisher_topic_id ' +
      'inner join user_topics as user_topic on user_topic.publisher_topic_id = topic.id ' +
      'inner join users as user on user.id = user_topic.user_id and story.id > user.top_story_id ' +
      "where user.id = ?", user.id
      ])
    #self.count_by_sql([
    #    'select count(*) from stories as story left join publisher_topics_stories as story_topic on story.id = story_topic.story_id ' +
    #    'where story.id > :eid and story_topic.publisher_topic_id in (:tids)', 
    #    { :eid => @user.top_story_id, :tids => @topic_ids }
    #  ])
  end

  def popularity
    if self.publisher.name == 'Digg'
      case self.publisher_votes
      when 0..99:       1
      when 100..299:    2
      when 300..499:    3
      when 500..999:    4
      when 1000..1999:  5
      when 2000..2999:  6
      when 3000..3999:  7
      when 4000..4999:  8
      when 5000..5999:  9
      else              10
      end
    else
      1
    end
  end

end

