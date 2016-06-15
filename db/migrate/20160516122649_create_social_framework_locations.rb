class CreateSocialFrameworkLocations < ActiveRecord::Migration
  def change
    create_table :social_framework_locations do |t|

      t.belongs_to :route, null: false

      t.decimal :latitude, null: false, precision: 18, scale: 15
      t.decimal :longitude, null: false, precision: 18, scale: 15
      t.timestamps null: false
    end
  end
end
