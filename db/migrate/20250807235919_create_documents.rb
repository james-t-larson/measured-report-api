class CreateDocuments < ActiveRecord::Migration[7.2]
  def up
    create_table :documents do |t|
      t.string :title
      t.string :link
      t.references :meeting, null: false, foreign_key: true
      t.timestamps

      add_index :documents, [ :meeting_id, :link ], unique: true, name: "index_documents_on_meeting_and_link"
    end
  end

  def down
    drop_table :documents
  end
end
