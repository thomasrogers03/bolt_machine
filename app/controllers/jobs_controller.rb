class JobsController < ApplicationController
  def index
    @jobs = Job.all
  end

  def edit
    job
  end

  def update
    job.update!(update_params)
    render json: job
  end

  def json_graph
    klass_script = %Q{Class.new do
      extend BehaviourNodeGraph
      class << self
        define_method(:graph) { {}.tap { |graph| #{job.job_script.script} } }
      end
    end}
    klass = eval(klass_script)
    graph = klass.graph
    render json: graph
  end

  private

  def job
    @job ||= Job.find(params[:id])
  end

  def update_params
    @update_params ||= params.require(:job).permit(:cron, :job_name, job_script_attributes: [:script, :id])
  end
end
