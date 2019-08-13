class AddUserIdForSelfCare < ActiveRecord::Migration[5.2]
  def change

    change_table :self_cares do |t|
      t.references :user, foreign_key: true, null: false, after: :self_care_classification_id
    end

  end
end
