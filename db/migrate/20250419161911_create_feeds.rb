class CreateFeeds < ActiveRecord::Migration[7.1]
  def change
    create_table :feeds do |t|
      t.string :url, null: false
      t.string :name, null: false
      t.string :content_class
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
