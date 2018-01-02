class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Rails use Notifications for own sql logging so we can override sql logger for orchestration
  def logger
    Foreman::Logging.logger('app')
  end

  # TODO: return a global id for graphql-activerecord
  def gid
    # add code to return a global object ID here
  end
end
