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
    json = JSON.parse(params[:json]).deep_symbolize_keys
    render text: YAML.dump(json)
  end

  private

  def execution_values
    @execution_values ||= YAML.load(params[:execution_values]) || {}
  end

  def job
    @job ||= Job.find(params[:id])
  end

  def update_params
    @update_params ||= params.require(:job).permit(:cron, :job_name, job_script_attributes: [:script, :id])
  end
end
