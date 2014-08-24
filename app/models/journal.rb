class Journal < ActiveRecord::Base
  belongs_to              :user
  has_many                :bookmarks, :class_name => 'JournalBookmark'
  has_and_belongs_to_many :publisher_topics
  has_many                :story_pins
  
  before_create           :supply_defaults

  #def self.find_by_safe_name!(safe_name)
  #  self.find_by_safe_name(safe_name) or raise ActiveRecord::RecordNotFound
  #end
  
  def self.find_by_safe_name_and_user!(safe_name, user)
    self.find_by_safe_name_and_user_id(safe_name, user.id) or raise ActiveRecord::RecordNotFound
  end

  def count_stories
    Journal.count_by_sql([
      'select count(*) from journals as journal ' +
      'inner join journals_publisher_topics as journal_topic on journal_topic.journal_id = journal.id ' +
      'inner join publisher_topics as topic on topic.id = journal_topic.publisher_topic_id ' +
      'inner join publisher_topics_stories as story_topic on story_topic.publisher_topic_id = topic.id ' +
      'inner join stories as story on story.id = story_topic.story_id ' +
      'where journal.id = :journal_id', 
      { :journal_id => self.id }
      ]);
  end

  #def find_page_stories_SLOW(page_number)
  #  Story.find(
  #    :all,
  #    :conditions => ['journal.id = ?', self.id],
  #    :order => 'stories.id asc',
  #    :joins =>
  #      'inner join publisher_topics_stories as story_topic on stories.id = story_topic.story_id ' +
  #      'inner join publisher_topics as topic on topic.id = story_topic.publisher_topic_id ' +
  #      'inner join journals_publisher_topics as journal_topic on journal_topic.publisher_topic_id = topic.id ' +
  #      'inner join journals as journal on journal.id = journal_topic.journal_id ' +
  #      'left join story_pins as story_pin on story_pin.story_id = stories.id',
  #    :include => [:publisher, :publisher_user, { :publisher_topics => :parent }, :pins],
  #    :limit => self.stories_per_page,
  #    :offset => page_number && page_number*self.stories_per_page
  #  )
  #end
  
  def find_page_stories(page_number)
    story_stubs = Story.find_by_sql([
      'select distinct stories.id from stories ' +
      'inner join publisher_topics_stories as story_topic on stories.id = story_topic.story_id ' +
      'inner join publisher_topics as topic on topic.id = story_topic.publisher_topic_id ' +
      'inner join journals_publisher_topics as journal_topic on journal_topic.publisher_topic_id = topic.id ' +
      'inner join journals as journal on journal.id = journal_topic.journal_id ' +
      'where journal.id = :journal_id ' +
      'order by stories.id asc ' +
      'limit :offset, :limit',
      { :journal_id => self.id, :limit => self.stories_per_page, :offset => page_number && page_number*self.stories_per_page }
    ])
    story_ids = story_stubs.collect { |story_stub| story_stub.id }
    Story.find(
      :all,
      :conditions => ['stories.id in (?)', story_ids],
      :order => 'stories.id asc',
#      :joins => 'left outer join story_pins as story_pin on story_pin.story_id = stories.id',
      :include => [:publisher, :publisher_user, { :publisher_topics => :parent }, :pins]
      )
  end
  
  def self.safe_name_for_name(name)
    # FIXME: need to make a lookup and make sure this name is unique for the given user
    name.downcase.gsub(/[^\w\-]/, '-')
  end
  
  private
  
  def supply_defaults
    # FIXME this hack for safe name is needed due to DB schema created incorrectly (?)
    self.safe_name = Journal.safe_name_for_name(self.name) unless self.safe_name && self.safe_name != ''
    self.direction ||= 1
    self.page ||= 1
    self.active ||= 1
    self.stories_per_page ||= 5
  end

end
