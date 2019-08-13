class CreateSelfCareClassifications < ActiveRecord::Migration[5.2]
  def change
    create_table :self_care_classifications do |t|
      t.string :name, null: false
      t.integer :order_number, limit: 3, null:false
      t.integer :kind, limit:1, null:false

      t.timestamps
    end
  end
end
