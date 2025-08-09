class CreateTranscripts < ActiveRecord::Migration[7.2]
  def up
    create_table :transcripts do |t|
      t.text :content
      t.string :external_id
      t.references :meeting, null: false, foreign_key: true
      t.references :video, null: false, foreign_key: true

      t.timestamps
    end
  end

  def down
    drop_table :transcripts
  end
end
