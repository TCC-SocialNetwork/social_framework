class CreateSocialFrameworkEventsSchedules < ActiveRecord::Migration
  def change
    create_table :social_framework_events_schedules do |t|
      t.belongs_to :schedule, index: true, null: false
      t.belongs_to :event, index: true, null: false
    end
  end
end
