class CreateSocialFrameworkEdgeRelationships < ActiveRecord::Migration
  def change
    create_table :social_framework_edge_relationships do |t|
      t.belongs_to :edge, index: true
      t.belongs_to :relationship, index: true
      t.boolean :active
    end
    add_index :social_framework_edge_relationships, [:edge_id, :relationship_id], unique: true,
                name: 'edges_and_relationships_unique'
  end
end
