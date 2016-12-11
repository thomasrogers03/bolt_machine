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
    node_klass.new_node
  end
end
