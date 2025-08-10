class CreateDocuments < ActiveRecord::Migration[7.2]
  def up
    create_table :documents do |t|
      t.string :title
      t.string :link
      t.references :meeting, null: false, foreign_key: true
      t.timestamps
    end
  end

  def down
    drop_table :documents
  end
end
