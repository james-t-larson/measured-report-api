class AddFeedEntryToArticles < ActiveRecord::Migration[7.1]
  def change
    add_reference :articles, :feed_entry, null: false, foreign_key: true
  end
end
