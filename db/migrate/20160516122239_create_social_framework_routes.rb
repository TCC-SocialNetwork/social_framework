class CreateSocialFrameworkRoutes < ActiveRecord::Migration
  def change
    create_table :social_framework_routes do |t|

      t.belongs_to :user, null: false
      t.string :title, null: false
      t.string :mode_of_travel, null: false, default: "driving"
      t.timestamps null: false
    end

    add_index :social_framework_routes, [:user_id, :title], unique: true
  end
end
