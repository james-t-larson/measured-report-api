class CreateArticles < ActiveRecord::Migration[7.2]
  def change
    create_table :articles do |t|
      t.string :title
      t.string :summary
      t.text :content
      t.string :sources
      t.references :category, null: false, foreign_key: true
      t.string :image
      t.float :sentiment
      t.integer :word_count
      t.integer :readability
      t.integer :pipeline, default: 0, null: false

      t.timestamps
    end
  end
end
