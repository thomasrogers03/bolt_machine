class Job < ActiveRecord::Base
  has_one :job_script, inverse_of: :job
  accepts_nested_attributes_for :job_script

  def node_meta_data
    @node_meta_data ||= NodeDefinition.all_node_types
  end
end
