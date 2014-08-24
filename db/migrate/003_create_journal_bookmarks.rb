class CreateJournalBookmarks < ActiveRecord::Migration
  def self.up
    create_table :journal_bookmarks do |t|
    end
  end

  def self.down
    drop_table :journal_bookmarks
  end
end
