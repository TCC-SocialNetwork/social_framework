class CreateSocialFrameworkEdges < ActiveRecord::Migration
  def change
    create_table :social_framework_edges do |t|
      t.references :origin, index: true
      t.references :destiny, index: true
      t.timestamps null: false
    end
  end
end
