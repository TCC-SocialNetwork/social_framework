class CreateSocialFrameworkEdgesRelationships < ActiveRecord::Migration
  def change
    create_table :social_framework_edges_relationships, id: false do |t|
      t.belongs_to :edge, index: true
      t.belongs_to :relationship, index: true
    end
  end
end
