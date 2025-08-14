class CreateTranscripts < ActiveRecord::Migration[7.2]
  def up
    create_table :transcripts do |t|
      t.text :vtt
      t.text :vtt_link
      t.string :external_id
      t.integer :pipeline, default: 0, null: false
      t.references :video, null: false, foreign_key: true

      t.timestamps
    end

    add_index :transcripts, :external_id, unique: true
  end

  def down
    drop_table :transcripts
  end
end
