class JobScript < ActiveRecord::Base
  belongs_to :job, inverse_of: :job_script

  def run(context)
    BehaviourNodeGraph::ImmediateExecutor.new(context).execute([create_node_graph])
  end

  def create_node_graph
    build_node(root, nodes[root]).value
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

  NodePlaceHolder = Struct.new(:value)

  def build_node(new_node_name, definition, existing_nodes = {})
    return existing_nodes[new_node_name] if existing_nodes.include?(new_node_name)

    new_node = NodePlaceHolder.new
    existing_nodes[new_node_name] = new_node
    node_definition = NodeDefinition.find_by(name: definition[:type])
    node_klass = if node_definition
                   node_definition.node_klass
                 else
                   "BehaviourNodeGraph::#{definition[:type]}".constantize
                 end

    input_values = node_klass.inputs.map { |name| definition[:inputs][name] }
    output_values = node_klass.outputs.map { |name| definition[:outputs][name] }
    output_node_values = node_klass.output_nodes.map do |name|
      node_name = definition[:output_nodes][name]
      node_definition = nodes[node_name]
      build_node(node_name, node_definition, existing_nodes).value
    end
    property_values = node_klass.properties.map { |name, _| definition[:properties][name] }

    next_node_values = (definition[:next_nodes] || []).map do |name|
      node_definition = nodes[name]
      build_node(name, node_definition, existing_nodes).value
    end

    new_node.value = node_klass.new_node(*input_values, *output_values, *output_node_values, *property_values)
    new_node.value.next_nodes = next_node_values
    new_node
  end
end
