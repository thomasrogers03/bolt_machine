class NodeDefinition < ActiveRecord::Base

  def self.all_node_types
    native_nodes = BehaviourNodeGraph.constants.map do |const|
      BehaviourNodeGraph.const_get(const)
    end.select { |const| const.respond_to?(:new_node) }.map do |node_klass|
      {'name' => node_klass.to_s.demodulize, 'inputs' => [], 'outputs' => [], 'properties' => {}}.merge(node_klass.as_json)
    end
    node_definitions = all.as_json
    (native_nodes + node_definitions).inject({}) do |memo, node_descriptor|
      memo.merge!(node_descriptor['name'] => node_descriptor)
    end
  end

  def as_json(*)
    {
        'name' => name,
        'inputs' => inputs,
        'outputs' => outputs,
        'output_nodes' => output_nodes,
        'properties' => properties
    }
  end

  def node_klass
    @node_klass ||= begin
      eval(node_klass_script).tap do |klass|
        klass.inputs = inputs
        klass.outputs = outputs
        klass.output_nodes = output_nodes
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
    @node_klass_params ||= (inputs + outputs + output_nodes + properties.keys).map { |key| ":#{key}" } * ', '
  end

  def inputs
    @inputs ||= (variable_meta_data['inputs'] || []).map(&:to_sym)
  end

  def outputs
    @outputs ||= (variable_meta_data['outputs'] || []).map(&:to_sym)
  end

  def output_nodes
    @output_nodes ||= (variable_meta_data['output_nodes'] || []).map(&:to_sym)
  end

  def properties
    @properties ||= (variable_meta_data['properties'] || {}).symbolize_keys
  end

  def variable_meta_data
    @variable_meta_data ||= YAML.load(meta_data.gsub("\t", '  ')) || {}
  end
end
