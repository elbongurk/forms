class CreateSubscriptions < ActiveRecord::Migration[5.0]
  def up
    create_table :subscriptions do |t|
      t.integer :user_id, null: false
      t.integer :plan_id, null: false
      t.integer :status, null: false, default: 0
      t.boolean :cancel_at_period_end, null: false, default: false
      t.datetime :period_start, null: false
      t.datetime :period_end
      t.datetime :canceled_at
      t.datetime :ended_at
      t.boolean :archived, null: false, default: false
      t.timestamps null: false
    end

    add_foreign_key :subscriptions, :users
    add_foreign_key :subscriptions, :plans
  end

  def down
    drop_table :subscriptions
  end
end
