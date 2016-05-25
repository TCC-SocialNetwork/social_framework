class CreateSocialFrameworkEvents < ActiveRecord::Migration
  def change
    create_table :social_framework_events do |t|
      t.string :title, null: false
      t.string :description
      t.timestamp :start
      t.timestamp :finish
      t.boolean :particular, default: false
      t.belongs_to :route
      t.timestamps null: false
    end
  end
end
