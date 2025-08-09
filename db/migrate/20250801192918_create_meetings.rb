class CreateMeetings < ActiveRecord::Migration[7.2]
  def up
    create_table :meetings do |t|
      t.string :title
      t.string :external_id
      t.string :location
      t.datetime :start_datetime, precision: 6, null: true
      t.datetime :end_datetime, precision: 6, null: true

      t.integer :document_pipeline, default: 0, null: false
      t.integer :video_pipeline, default: 0, null: false
      t.integer :transcript_pipeline, default: 0, null: false

      t.timestamps
    end
  end

  def down
    drop_table :meetings
  end
end
