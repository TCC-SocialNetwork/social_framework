class CreateSocialFrameworkSchedules < ActiveRecord::Migration
  def change
    create_table :social_framework_schedules do |t|

      t.belongs_to :user, null: false
      t.timestamps null: false
    end

    add_index :social_framework_schedules, :user_id, unique: true
  end
end
