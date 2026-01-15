class CreateTitles < ActiveRecord::Migration[7.2]
  def change
    create_table :titles do |t|
      t.string :external_id, null: false
      t.string :name, null: false
      t.string :title_type, null: false  # 'movie' or 'series'

      t.timestamps
    end

    add_index :titles, :external_id, unique: true
    add_index :titles, :title_type
  end
end
