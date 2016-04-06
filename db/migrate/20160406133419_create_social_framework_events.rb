class CreateSocialFrameworkEvents < ActiveRecord::Migration
  def change
    create_table :social_framework_events do |t|

      # t.belongs_to :creator, index: true, null: false
      t.string :title, null: false
      t.string :description
      t.datetime :start
      t.datetime :finish
      t.boolean :particular, default: false
      t.timestamps null: false
    end
  end
end
