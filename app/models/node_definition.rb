class NodeDefinition < ActiveRecord::Base
  def node_klass
    @node_klass ||= eval(node_klass_script)
  end

  private

  def node_klass_script
    @node_klass_script ||= %Q{BehaviourNodeGraph.define_simple_node do
  #{script}
end}
  end
end
