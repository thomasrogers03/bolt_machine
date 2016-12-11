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

  NodeDefinition.create!(name: 'DebugNode', script: %q{puts "=> DEBUG: #{context.values.inspect}"}, meta_data: "---\n")
  dummy_meta_data = %q{---
inputs:
	- source
outputs:
	- target
properties:
	- property
}
  NodeDefinition.create!(name: 'TestNode', script: 'context.values[target] = context.values[source]', meta_data: dummy_meta_data)
end
