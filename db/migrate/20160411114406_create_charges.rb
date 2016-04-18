class CreateCharges < ActiveRecord::Migration[5.0]
  def up
    create_table :charges do |t|
      t.string :payment_token, null: false
      t.integer :subscription_id, null: false
      t.integer :card_id, null: false
      t.integer :amount, null: false, default: 0
      t.boolean :paid, null: false, default: false
      t.string :failure_code
      t.string :failure_message
      t.timestamps null: false
    end

    add_foreign_key :charges, :subscriptions
    add_foreign_key :charges, :cards
  end

  def down
    drop_table :charges
  end
end
