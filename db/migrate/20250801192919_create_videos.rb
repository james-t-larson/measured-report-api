class CreateVideos < ActiveRecord::Migration[7.2]
  def up
    create_table :videos do |t|
      t.string :title
      t.string :link
      t.string :external_id
      t.references :meeting, null: false, foreign_key: true

      t.timestamps
    end
  end

  def down
    drop_table :videos
  end
end
