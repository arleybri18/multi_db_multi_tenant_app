class CreateAuthors < ActiveRecord::Migration[7.1]
  def change
    create_table :authors do |t|
      t.string :slug
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
