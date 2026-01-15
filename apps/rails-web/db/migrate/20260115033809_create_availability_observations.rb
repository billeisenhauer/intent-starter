class CreateAvailabilityObservations < ActiveRecord::Migration[7.2]
  def change
    create_table :availability_observations do |t|
      t.references :title, null: false, foreign_key: true
      t.string :platform, null: false
      t.references :observer, null: false, foreign_key: { to_table: :members }
      t.decimal :confidence, precision: 5, scale: 4, null: false
      t.datetime :observed_at, null: false

      t.timestamps
    end

    add_index :availability_observations, [:title_id, :platform, :observer_id],
              name: 'idx_availability_obs_title_platform_observer'
    add_index :availability_observations, :observed_at
  end
end
