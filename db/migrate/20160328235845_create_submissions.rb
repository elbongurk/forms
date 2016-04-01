class CreateSubmissions < ActiveRecord::Migration[5.0]
  def up
    create_table :submissions do |t|
      t.integer :form_id, null: false
      t.json :payload
      t.timestamps null: false
    end

    add_foreign_key :submissions, :forms
  end

  def down
    drop_table :submissions
  end
end
