class JobsController < ApplicationController
  before_action { @title = 'Jobs' }

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

  def execute
    context = BehaviourNodeGraph.context.new
    context.values.merge!(execution_values)
    job.job_script.run(context)
  end

  private

  def execution_values
    YAML.load(params[:execution_values])
  end

  def job
    @job ||= Job.find(params[:id])
  end

  def update_params
    @update_params ||= params.require(:job).permit(:cron, :job_name, job_script_attributes: [:script, :id])
  end
end
