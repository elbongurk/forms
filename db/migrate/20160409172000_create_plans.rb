class CreatePlans < ActiveRecord::Migration[5.0]
  def up
    create_table :plans do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.integer :price, null: false, default: 0
      t.integer :form_quota, null: false
      t.integer :trial_period_days, null: false, default: 30
      t.integer :sort, null: false
      t.boolean :default, null: false, default: false
      t.boolean :archived, null: false, default: false
      t.timestamps null: false
    end

    add_index :plans, :name, unique: true
  end

  def down
    drop_table :plans
  end
end
