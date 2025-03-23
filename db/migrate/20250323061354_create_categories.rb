class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.string :slug
      t.string :name
      t.bigint :position

      t.timestamps
    end
  end
end
