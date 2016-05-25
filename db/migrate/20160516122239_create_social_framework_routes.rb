class CreateSocialFrameworkRoutes < ActiveRecord::Migration
  def change
    create_table :social_framework_routes do |t|

      t.string :title, null: false
      t.integer :distance, null: false
      t.string :mode_of_travel, null: false, default: "driving"
      t.timestamps null: false
    end

    create_table :social_framework_routes_users do |t|

      t.belongs_to :user, null: false, index: true
      t.belongs_to :route, null: false, index: true
    end

    add_index :social_framework_routes_users, [:user_id, :route_id], unique: true
  end
end
