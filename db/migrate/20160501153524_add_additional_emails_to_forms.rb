class AddAdditionalEmailsToForms < ActiveRecord::Migration[5.0]
  def up
    add_column :forms, :additional_emails, :string, array: true, default: []
    add_index :forms, :additional_emails, using: :gin
  end

  def down
    remove_column :forms, :additional_emails
  end
end
