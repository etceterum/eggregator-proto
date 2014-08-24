class StoryController < ApplicationController
  layout 'main'

  before_filter :login_required

  # FIXME: obtain from user prefs
  STORIES_PER_PAGE = 10

  def index
    list
    render :action => 'list'
  end

  def list

    @user = session[:user]
    @page = params[:id] || 1
    @page_index = @page.to_i - 1

    # topics the user is subscribed to
    #@user_topics = UserTopic.find(
    #  :all,
    #  :conditions => ['user_id = ?', @user.id]
    #  )
    #@topic_ids = @user_topics.collect { |user_topic| user_topic.publisher_topic_id }

    # find out how many present stories and pages of stories the user has
    @present_story_count = Story.count_present_by_user(@user)
    @present_page_count = @present_story_count/STORIES_PER_PAGE
    @present_page_count += 1 if @present_story_count%STORIES_PER_PAGE > 0

    # fetch stories for the page to be displayed
    @page_stories = Story.find_present_by_user_and_page(@user, STORIES_PER_PAGE, @page_index)

    # count future stories
    @future_story_count = Story.count_future_by_user(@user)

  end

end
