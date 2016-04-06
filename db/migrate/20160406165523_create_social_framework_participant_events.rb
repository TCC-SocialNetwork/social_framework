class CreateSocialFrameworkParticipantEvents < ActiveRecord::Migration
  def change
    create_table :social_framework_participant_events do |t|
      t.belongs_to :event, index: true, null: false
      t.belongs_to :schedule, index: true, null: false
      t.boolean :confirmed, default: false
      t.string :role, default: "participant"
    end
  end
end
