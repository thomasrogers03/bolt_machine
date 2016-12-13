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
  NodeDefinition.destroy_all

  job_script = %q{---
:root: run_this
:nodes:
  run_this:
    :type: TestNode
    :inputs:
      :source: :some_input_variable
    :outputs:
      :target: :some_output_variable
    :properties:
      :property: 12345
    :next_nodes:
      - run_this_next
  run_this_next:
    :type: RunJob
    :properties:
      :job: Test Job 2
}
  Job.create!(job_name: 'Test Job', job_script_attributes: {script: job_script})

  job_two_script = %q{---
:root: run_this
:nodes:
  run_this:
    :type: SetConstant
    :outputs:
      :target: :some_constant
    :properties:
      :value: 9999
}
  Job.create!(job_name: 'Test Job 2', job_script_attributes: {script: job_two_script})

  job_three_script = %q{---
:root: run_this
:nodes:
  run_this:
    :type: SetConstant
    :outputs:
      :target: :url
    :properties:
      :value: http://www.example.com
    :next_nodes:
      - run_this_next
  run_this_next:
    :type: PretendVisitPage
    :inputs:
      :url: :url
    :outputs:
      :page_content: :page_content
}
  Job.create!(job_name: 'Visit Example Website', job_script_attributes: {script: job_three_script})



  NodeDefinition.create!(name: 'DebugNode', script: %q{puts "=> DEBUG: #{context.values.inspect}"}, meta_data: "---\n")

  dummy_meta_data = %q{---
:inputs:
  - :source
:outputs:
  - :target
:properties:
  :property: :any
}
  NodeDefinition.create!(name: 'TestNode', script: 'context.values[target] = context.values[source]', meta_data: dummy_meta_data)

  run_job_meta_data = %q{---
:properties:
  :job: :string
}
  NodeDefinition.create!(name: 'RunJob', script: 'Job.find_by!(job_name: job).job_script.run(context)', meta_data: run_job_meta_data)

  visit_page_meta_data = %q{---
:outputs:
  - :page_content
:inputs:
  - :url
}
  NodeDefinition.create!(name: 'VisitPage', script: 'context.values[page_content] = URI.parse(context.values[url]).open.read', meta_data: visit_page_meta_data)

  fake_visit_page_meta_data = %q{---
:outputs:
  - :page_content
:inputs:
  - :url
}
  NodeDefinition.create!(name: 'PretendVisitPage', script: 'context.values[page_content] = "Content from #{context.values[url]}"', meta_data: fake_visit_page_meta_data)
end
