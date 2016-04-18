class AddPaymentTokenToUsers < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :payment_token, :string
  end

  def down
    remove_column :users, :payment_token
  end
end
