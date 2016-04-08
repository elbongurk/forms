class AddPasswordResetToUsers < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :password_reset_token, :string
    add_column :users, :password_reset_requested_at, :datetime

    add_index :users, :password_reset_token, unique: true
  end

  def down
    remove_column :users, :password_reset_token
    remove_column :users, :password_reset_requested_at
  end
end
