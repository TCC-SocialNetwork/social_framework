class CreateSocialFrameworkParticipantEvents < ActiveRecord::Migration
  def change
    create_table :social_framework_participant_events do |t|
      t.belongs_to :event, index: true, null: false
      t.belongs_to :schedule, index: true, null: false
      t.boolean :confirmed, default: false
      t.string :role, default: "participant"
    end

    add_index :social_framework_participant_events, [:schedule_id, :event_id], unique: true, name: :participant_event
  end
end
