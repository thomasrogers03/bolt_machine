# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Job.transaction do
  Job.destroy_all
  JobScript.destroy_all

  Job.create!(job_name: 'Test Job', job_script_attributes: {script: ''})

  NodeDefinition.create!(name: 'DebugNode', script: 'puts context.values.inspect')
end
