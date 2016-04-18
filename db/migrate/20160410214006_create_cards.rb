class CreateCards < ActiveRecord::Migration[5.0]
  def up
    create_table :cards do |t|
      t.string :payment_token, null: false
      t.integer :user_id, null: false
      t.string :brand
      t.string :last4
      t.integer :exp_month
      t.integer :exp_year
      t.string :name
      t.boolean :default, null: false, default: false
      t.boolean :archived, null: false, default: false
      t.timestamps null: false
    end

    add_foreign_key :cards, :users
  end

  def down
    drop_table :cards
  end
end
