require 'graphql'
require 'graphql/batch'

# This proc is used when you're authorizing changes to a model inside of a mutator:
GraphQL::Models.authorize = ->(context, action, model) {
  # Action will be either :create, :update, or :destroy
  # Raise an exception if the action should not proceed
  user = context['user']
  # TODO
  model.authorize_changes!(action, user)
}

GraphQL::Models::DatabaseTypes.register(:text, 'GraphQL::STRING_TYPE')
GraphQL::Models::DatabaseTypes.register(:datetime, 'Types::DateTimeType')
