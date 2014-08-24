class CreateJournals < ActiveRecord::Migration
  def self.up
    create_table :journals do |t|
    end
  end

  def self.down
    drop_table :journals
  end
end
