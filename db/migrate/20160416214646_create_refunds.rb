class CreateRefunds < ActiveRecord::Migration[5.0]
  def up
    create_table :refunds do |t|
      t.string :payment_token, null: false
      t.integer :charge_id, null: false
      t.integer :amount, null: false, default: 0
      t.timestamps null: false
    end
    add_foreign_key :refunds, :charges
  end

  def down
    drop_table :refunds
  end
end
