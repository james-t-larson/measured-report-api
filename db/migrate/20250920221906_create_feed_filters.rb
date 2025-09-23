class CreateFeedFilters < ActiveRecord::Migration[7.2]
  def change
    create_table :feed_filters do |t|
      t.references :feed, null: false, foreign_key: true
      t.string :pattern
      t.string :function

      t.timestamps
    end
  end
end
