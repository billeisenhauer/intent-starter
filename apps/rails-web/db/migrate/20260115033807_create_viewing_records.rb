class CreateViewingRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :viewing_records do |t|
      t.references :member, null: false, foreign_key: true
      t.references :title, null: false, foreign_key: true
      t.decimal :progress, precision: 5, scale: 4, default: 0.0, null: false
      t.boolean :fully_watched, default: false, null: false

      t.timestamps
    end

    add_index :viewing_records, [:member_id, :title_id], unique: true
    add_index :viewing_records, :fully_watched
  end
end
