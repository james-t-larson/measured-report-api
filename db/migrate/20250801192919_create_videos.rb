class CreateVideos < ActiveRecord::Migration[7.2]
  def up
    create_table :videos do |t|
      t.string :title
      t.string :link
      t.string :external_id
      t.integer :pipeline, default: 0, null: false
      t.references :meeting, null: false, foreign_key: true

      t.timestamps
    end

    add_index :videos, :external_id, unique: true
  end

  def down
    drop_table :videos
  end
end
