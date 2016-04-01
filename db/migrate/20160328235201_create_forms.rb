class CreateForms < ActiveRecord::Migration[5.0]
  def up
    create_table :forms do |t|
      t.string :uid, null: false
      t.string :name, null: false
      t.string :redirect_url
      t.boolean :email, null: false, default: false
      t.integer :user_id, null: false
      t.timestamps null: false
    end

    add_index :forms, :uid, unique: true
    add_foreign_key :forms, :users
  end

  def down
    drop_table :forms
  end
end
