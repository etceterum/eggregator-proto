class CreateUserTopics < ActiveRecord::Migration
  def self.up
    create_table :user_topics do |t|
    end
  end

  def self.down
    drop_table :user_topics
  end
end
