class CreateSocialFrameworkRelationships < ActiveRecord::Migration
  def change
    create_table :social_framework_relationships do |t|
      t.string :label, null: false, default: ""
      t.timestamps null: false
    end
  end
end
