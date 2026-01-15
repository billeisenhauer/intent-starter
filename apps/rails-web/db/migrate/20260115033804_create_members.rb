class CreateMembers < ActiveRecord::Migration[7.2]
  def change
    create_table :members do |t|
      t.references :household, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end

    add_index :members, [:household_id, :name], unique: true
  end
end
