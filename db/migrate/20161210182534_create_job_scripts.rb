class CreateJobScripts < ActiveRecord::Migration
  def change
    create_table :job_scripts do |t|
      t.belongs_to :job
      t.string :script
      t.timestamps
    end
  end
end
