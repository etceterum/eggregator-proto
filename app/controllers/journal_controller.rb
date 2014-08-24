require_dependency "agg/widget"

class JournalController < ApplicationController

  before_filter :login_required

  # edit journal properties, or create a new journal
  def edit
    @user = session[:user]

    if params[:name]
      @journal = Journal.find_by_safe_name_and_user!(params[:name], @user)
    else 
      @journal = Journal.new
    end


    # all topics in the database
    topics = PublisherTopic.find(:all, :include => [:publisher], :order => 'publisher_topics.name')
    
    # all publishers in the database
    @publishers = topics.collect { |topic| topic.publisher }.uniq
    
    # build hierarchy of topics by publisher
    @topics_by_publisher = {}
    @publishers.each do |publisher| 
      @topics_by_publisher[publisher] = {}
      # separate topics that belong to this publisher, from all other topics
      this_publisher_topics, topics = topics.partition { |topic| topic.publisher == publisher }
      # separate root topics from non-root topics for this publisher
      root_topics, non_root_topics = this_publisher_topics.partition { |topic| !topic.parent_id }
      root_topics.each do |topic|
        @topics_by_publisher[publisher][topic], non_root_topics = build_topic_hierarchy(topic, non_root_topics)
      end
    end
  end
  
  # save changes done to an existing journal, or create a new journal
  # TODO: eliminate this method by merging its POST functionality into the edit method
  def save
    unless request.post?
      edit
      render :action => 'edit'
      return 
    end
    
    @user = session[:user]
    @journal_id = params[:journal][:id]
    if @journal_id
      # update an existing journal
      @journal = Journal.find(@journal_id)
      @journal.update_with_attributes(params[:journal])
    else
      # create a new journal
      #@journal = Journal.create(
      #  :user => @user,
      #  :name => params[:journal][:name],
      #  :safe_name => Journal.safe_name_for_name(params[:journal][:name]),
      #  :direction => 1,
      #  :page => 1,
      #  :active => 1,
      #  :stories_per_page => 5,
      #  :publisher_topic_ids => params[:journal][:publisher_topic_ids]
      #  )
      @journal = Journal.create(params[:journal].merge({ :user => @user }))
    end
    
    edit
    render :action => 'edit'
    
  end
  
  # view journal entries for a given journal, authenticated user and (optionally) a given page
  def view

    @user = session[:user]

    @safe_name = params[:name] or (render_404 and return)

    @journal = Journal.find_by_safe_name_and_user!(@safe_name, @user)

    @page = params[:page] || @journal.page
    begin
      @page = Integer(@page)
      @page = 1 if @page < 1
    rescue
      @page = 1
    end
    
    # memorize the new page as the last visited page if:
    # a) page was specified as a parameter, and
    # b) using POST method
    #if params[:page] && request.post?
    #  @journal.page = @page
    #  @journal.save!
    #end
    
    @title = [@journal.name, "Page #{@page}"]
    @javascript_includes = ['journal']

    logger.debug("JournalController::View: Counting Stories")
    @story_count = @journal.count_stories
    logger.debug("JournalController::View: Done Counting Stories")
    @page_count = @story_count / @journal.stories_per_page
    @page_count += 1 if @story_count % @journal.stories_per_page > 0

    @page = @page_count if @page > @page_count
    @page = 1 if @page < 1
    @page0 = @page - 1
    
    logger.debug("JournalController::View: Fetching Stories for Current Page")
    @page_stories = @journal.find_page_stories(@page0)
    logger.debug("JournalController::View: Done Fetching Stories for Current Page")
    
    # widgets
    # TODO: make the list of widgets configurable per user
    @widgets = [ Agg::Widget::MyJournals.new(self, @user) ]
    
  end
  
  # rememeber the given page as the last visited page of the journal for the authenticated user,
  # and go to that page
  def pin_page
    @user = session[:user]
    @journal = Journal.find(params[:id])
    @page = Integer(params[:page])
    
    case request.method
    when :post
      if @page != @journal.page
        @journal.page = @page
        @journal.save!
      end
      render :partial => 'pin_page_response'
    else
      redirect_to :action => 'list', :name => @journal.safe_name, :page => @page
    end
    
  end

  # remember the given story for the authenticated user
  def pin_story
    @user = session[:user]
    @story = Story.find(params[:story_id])
    @journal = Journal.find(params[:id])
    @page = Integer(params[:page])

    @story_pin = StoryPin.find_by_story_id_and_journal_id_and_user_id(@story.id, @journal.id, @user.id)
    if @story_pin
      @story_pin.destroy
      @story_pin = nil
    else
      @story_pin = StoryPin.create(:story => @story, :journal => @journal, :user => @user)
    end

    case request.method
    when :post
      render :partial => 'pin_story_response'
    else
      redirect_to :action => 'list', :name => @journal.safe_name, :page => @page
    end
  end
  
  private
  
  def build_topic_hierarchy(root_topic, topics)
    result = {}
    children, others = topics.partition { |topic| topic.parent_id == root_topic.id }
    children.each do |child|
      result[child], others = build_topic_hierarchy(child, others)
    end
    [result, others]
  end

end
