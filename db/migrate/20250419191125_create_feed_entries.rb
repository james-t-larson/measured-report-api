class CreateFeedEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :feed_entries do |t|
      t.references :feed, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :guid, null: false
      t.string :title
      t.string :summary
      t.string :url
      t.string :image
      t.text :content, null: false
      t.float :sentiment_score, null: false
      t.integer :generation_edict, default: 0, null: false
      t.datetime :published_at

      t.timestamps
    end

    add_index :feed_entries, [ :feed_id, :guid, :url ], unique: true
  end
end
