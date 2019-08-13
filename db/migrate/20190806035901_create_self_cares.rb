class CreateSelfCares < ActiveRecord::Migration[5.2]
  def change
    create_table :self_cares do |t|
      t.references :self_care_classification, foreign_key: true, null: false
      t.datetime :log_date, null: false
      t.text :reason, null: false
      t.integer :point, limit:2, null:false
      t.timestamps

    end
  end
end
