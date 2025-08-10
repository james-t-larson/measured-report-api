class CreateMeetings < ActiveRecord::Migration[7.2]
  def up
    create_table :meetings do |t|
      t.string :title
      t.string :external_id
      t.string :location
      t.datetime :start_datetime, precision: 6, null: true
      t.datetime :end_datetime, precision: 6, null: true

      t.timestamps
    end

    add_index :meetings, :external_id, unique: true
  end

  def down
    drop_table :meetings
  end
end
