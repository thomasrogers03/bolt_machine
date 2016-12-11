class CreateNodeDefinitions < ActiveRecord::Migration
  def change
    create_table :node_definitions do |t|
      t.string :name, index: true
      t.string :script
      t.string :meta_data
      t.timestamps
    end
  end
end
