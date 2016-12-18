class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :cron
      t.boolean :enabled
      t.string :job_name, index: true
      t.timestamps
    end
  end
end
