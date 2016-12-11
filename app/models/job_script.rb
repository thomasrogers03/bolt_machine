class JobScript < ActiveRecord::Base
  belongs_to :job, inverse_of: :job_script
end
