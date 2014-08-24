class UserController < ApplicationController

  def login
    case @request.method
      when :post
      if @session[:user] = User.authenticate(@params[:user_login], @params[:user_password])

        flash['notice']  = "Login successful"
        redirect_back_or_default :action => "profile"
      else
        flash.now['notice']  = "Login unsuccessful"

        @login = @params[:user_login]
      end
    end
  end
  
  def signup
    @user = User.new(@params[:user])

    @user.active = 1
    @user.top_story = Story.find(:first, :order => 'id desc')
    @user.bottom_story = Story.find(:first, :order => 'id asc')
    @user.publisher_topics = PublisherTopic.find(:all)

    if @request.post? and @user.save
      @session[:user] = User.authenticate(@user.login, @params[:user][:password])
      flash['notice']  = "Signup successful"
      redirect_back_or_default :action => "profile"
    end      
  end  
  
  def logout
    @session[:user] = nil
  end

  def index
    profile
    render :action => 'profile'
  end
    
  def profile
    @user = session[:user]
  end
    
  def whatever
    redirect_to :controller => 'user', :action => 'not_implemented'
    return

    # list of topics with their respective publishers
    @topic_list = PublisherTopic.find(:all, :include => [:publisher])
    @user = session[:user]
    # list of current user topics
    @user_topic_list = @user.publisher_topics

    case @request.method
    when :post 
      @topic_status_by_id = params[:topic] || []
      @topic_status_by_id.keys.each do |topic_id|
        subscribed = @topic_status_by_id[topic_id]
        user_topic = @user_topic_list.any? { |topic| topic.id == topic_id.to_i }
        if subscribed && !user_topic
          @user_topic_list << PublisherTopic.find(topic_id)
        elsif !subscribed && user_topic
          @user_topic_list.delete user_topic
        end
      end
      @user.save!
    end

    # hierarchy of topics
    @topic_map = {}
    @topic_list.each do |topic|
      @topic_map[topic.parent_id || 0] = [] unless @topic_map[topic.parent_id || 0]
      @topic_map[topic.parent_id || 0] << topic
    end
    @topic_map.keys.each do |topic_id|
      @topic_map[topic_id] = @topic_map[topic_id].sort_by { |topic| topic.name }
    end

    # list of top level topics
    @top_level_topic_list = @topic_list.find_all { |topic| !topic.parent_id }

    # list of top level topics by publisher
    @publisher_top_level_topic_map = {}
    @top_level_topic_list.each do |topic|
      @publisher_top_level_topic_map[topic.publisher] = [] unless @publisher_top_level_topic_map[topic.publisher]
      @publisher_top_level_topic_map[topic.publisher] << topic
    end
    @publisher_top_level_topic_map.keys.each do |publisher|
      @publisher_top_level_topic_map[publisher] = @publisher_top_level_topic_map[publisher].sort_by { |topic| topic.name }
    end

    # list of publishers
    @publisher_list = @publisher_top_level_topic_map.keys.sort_by { |publisher| publisher.name }

    @user_subscribed = {}
    @user_topic_list.each do |topic|
      @user_subscribed[topic] = true
    end

    @stylesheet_includes = ['tabs']
    @javascript_includes = ['tabber/tabber']

  end

  def not_implemented
  end

end
