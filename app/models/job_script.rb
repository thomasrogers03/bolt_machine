class JobScript < ActiveRecord::Base
  belongs_to :job, inverse_of: :job_script

  def create_node_graph
    build_node(nodes[root])
  end

  def root
    definition[:root]
  end

  def nodes
    @nodes ||= definition[:nodes] || {}
  end

  def definition
    @definition ||= YAML.load(script) || {}
  end

  private

  def build_node(definition)
    node_definition = NodeDefinition.find_by(name: definition[:type])
    node_klass = if node_definition
                   node_definition.node_klass
                 else
                   "BehaviourNodeGraph::#{definition[:type]}".constantize
                 end
    input_values = node_klass.inputs.map { |name| definition[:inputs][name] }
    output_values = node_klass.outputs.map { |name| definition[:outputs][name] }
    output_node_values = node_klass.output_nodes.map { |name| definition[:output_nodes][name] }
    property_values = node_klass.properties.map { |name, _| definition[:properties][name] }
    node_klass.new_node(*input_values, *output_values, *output_node_values, *property_values)
  end
end
