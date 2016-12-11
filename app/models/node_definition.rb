class NodeDefinition < ActiveRecord::Base
  def node_klass
    @node_klass ||= eval(node_klass_script)
  end

  def node_klass_script
    @node_klass_script ||= %Q{BehaviourNodeGraph.define_simple_node(#{node_klass_params}) do
  #{script}
end}
  end

  def node_klass_params
    @node_klass_params ||= (inputs + outputs + properties.keys).map { |key| ":#{key}" } * ', '
  end

  def inputs
    @inputs ||= variable_meta_data[:inputs] || []
  end

  def outputs
    @outputs ||= variable_meta_data[:outputs] || []
  end

  def properties
    @properties ||= variable_meta_data[:properties] || []
  end

  def variable_meta_data
    @variable_meta_data ||= YAML.load(meta_data.gsub("\t", '  ')) || {}
  end
end
