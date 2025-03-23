class CreateArticles < ActiveRecord::Migration[7.2]
  def change
    create_table :articles do |t|
      t.string :title
      t.string :summary
      t.text :content
      t.string :sources
      t.references :category, null: false, foreign_key: true
      t.string :image
      t.float :sentiment_score

      t.timestamps
    end
  end
end
