class CreateStoryPins < ActiveRecord::Migration
  def self.up
    create_table :story_pins do |t|
    end
  end

  def self.down
    drop_table :story_pins
  end
end
