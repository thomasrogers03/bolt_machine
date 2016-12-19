class JobsController < ApplicationController
  before_action { @title = 'Jobs' }

  def index
    @jobs = Job.all
    @new_job = Job.new
  end

  def edit
    job
  end

  def create
    job = Job.create!(create_job_params.merge(job_script_attributes: {script: "---\n"}))
    redirect_to edit_job_path(job)
  end

  def update
    job.update!(update_params)
    if params[:designer]
      render json: job
    else
      redirect_to jobs_path
    end
  end

  def execute
    result = begin
      context = BehaviourNodeGraph::Context.new
      context.values.merge!(execution_values)
      job.job_script.run(context)
      context.values
    rescue Exception => error
      {error: {type: error.class.to_s.demodulize, message: error.message, backtrace: error.backtrace}}
    end
    render text: YAML.dump(result)
  end

  def script_json
    render json: job.job_script.job_script_as_json
  end

  def json_to_yaml
    json = JSON.parse(params[:json])
    render text: YAML.dump(json)
  end

  private

  def execution_values
    @execution_values ||= YAML.load(params[:execution_values]) || {}
  end

  def job
    @job ||= Job.find(params[:id])
  end

  def create_job_params
    @create_job_params ||= params.require(:job).permit(:job_name)
  end

  def update_params
    @update_params ||= params.require(:job).permit(:cron, :job_name, job_script_attributes: [:script, :id])
  end
end
