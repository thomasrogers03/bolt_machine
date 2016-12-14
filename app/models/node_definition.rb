class NodeDefinition < ActiveRecord::Base
  def node_klass
    @node_klass ||= begin
      eval(node_klass_script).tap do |klass|
        klass.inputs = inputs
        klass.outputs = outputs
        klass.output_nodes = []
        klass.properties = properties
      end
    end
  end

  def node_klass_script
    @node_klass_script ||= %Q{klass = BehaviourNodeGraph.define_simple_node(#{node_klass_params}) do
  #{script}
end}
  end

  def node_klass_params
    @node_klass_params ||= (inputs + outputs + properties.keys).map { |key| ":#{key}" } * ', '
  end

  def inputs
    @inputs ||= (variable_meta_data['inputs'] || []).map(&:to_sym)
  end

  def outputs
    @outputs ||= (variable_meta_data['outputs'] || []).map(&:to_sym)
  end

  def properties
    @properties ||= (variable_meta_data['properties'] || {}).symbolize_keys
  end

  def variable_meta_data
    @variable_meta_data ||= YAML.load(meta_data.gsub("\t", '  ')) || {}
  end
end
