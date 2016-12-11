class NodeDefinitionsController < ApplicationController
  def index
    @node_definitions = NodeDefinition.all
  end

  def edit
    node_definition
  end

  def update
    node_definition.update!(update_params)
    render json: node_definition
  end

  private

  def node_definition
    @node_definition ||= NodeDefinition.find(params[:id])
  end

  def update_params
    @update_params ||= params.require(:node_definition).permit(:name, :script)
  end
end
