class NodeDefinitionsController < ApplicationController
  before_action { @title = 'Node Definition' }

  def index
    @node_definitions = NodeDefinition.all
    @new_node_definition = NodeDefinition.new
  end

  def edit
    node_definition
  end

  def create
    node_definition = NodeDefinition.create!(create_node_params.merge(meta_data: "---\n"))
    redirect_to edit_node_definition_path(node_definition)
  end

  def update
    node_definition.update!(update_params)
    render json: node_definition
  end

  def node_ports
    node_definition = NodeDefinition.find_by(name: params[:type]) || "BehaviourNodeGraph::#{params[:type]}".constantize
    inputs = node_definition.inputs || []
    outputs = node_definition.outputs || []
    render json: {in_ports: %w(in) + inputs, out_ports: %w(next_nodes) + outputs}
  end

  private

  def node_definition
    @node_definition ||= NodeDefinition.find(params[:id])
  end

  def create_node_params
    @create_node_params ||= params.require(:node_definition).permit(:name)
  end

  def update_params
    @update_params ||= params.require(:node_definition).permit(:name, :script, :meta_data)
  end
end
