class CreateSocialFrameworkRelationships < ActiveRecord::Migration
  def change
    create_table :social_framework_relationships do |t|
      t.string :label, null: false, default: ""
      t.timestamps null: false
    end
    add_index :social_framework_relationships, :label, unique: true
  end
end
