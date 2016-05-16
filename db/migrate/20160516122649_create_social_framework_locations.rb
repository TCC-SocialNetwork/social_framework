class CreateSocialFrameworkLocations < ActiveRecord::Migration
  def change
    create_table :social_framework_locations do |t|

      t.belongs_to :route, null: false

      t.decimal :latitude, null: false
      t.decimal :longitude, null: false
      t.timestamps null: false
    end
  end
end
