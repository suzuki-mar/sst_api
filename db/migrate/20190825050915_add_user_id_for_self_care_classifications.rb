# frozen_string_literal: true

class AddUserIdForSelfCareClassifications < ActiveRecord::Migration[5.2]
  def change
    change_table :self_care_classifications do |t|
      t.references :user, foreign_key: true, null: false, after: :id
    end
  end
end
