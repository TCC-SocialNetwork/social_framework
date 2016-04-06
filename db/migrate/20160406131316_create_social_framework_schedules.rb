class CreateSocialFrameworkSchedules < ActiveRecord::Migration
  def change
    create_table :social_framework_schedules do |t|

      t.belongs_to :user, index: true, null: false
      t.timestamps null: false
    end
  end
end
