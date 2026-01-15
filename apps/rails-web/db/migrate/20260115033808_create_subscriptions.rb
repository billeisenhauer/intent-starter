class CreateSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :subscriptions do |t|
      t.references :household, null: false, foreign_key: true
      t.string :platform, null: false
      t.decimal :monthly_cost, precision: 8, scale: 2, null: false
      t.boolean :active, default: true, null: false
      t.datetime :last_watched_at

      t.timestamps
    end

    add_index :subscriptions, [:household_id, :platform], unique: true
    add_index :subscriptions, :active
  end
end
