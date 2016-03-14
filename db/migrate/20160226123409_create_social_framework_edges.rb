class CreateSocialFrameworkEdges < ActiveRecord::Migration
  def change
    create_table :social_framework_edges do |t|
      t.belongs_to :origin, index: true, null: false
      t.belongs_to :destiny, index: true, null: false
      t.string :label, null: false
      t.boolean :bidirectional, null: false, default: true
      t.boolean :active, null: false, default: false
      t.timestamps null: false
    end
  end
end
