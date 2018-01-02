module Fields
  class FetchField
    def self.build(model:, type:)
      return_type = type
      GraphQL::Field.define do
        type(return_type)
        description("Find a #{model.name} by ID")
        argument(:id, !types.Int, "ID for Record")
        resolve ->(obj, args, ctx) {
          scope = if model.respond_to?(:authorized)
                    permission = model.permission_name(:view)
                    model.authorized_as(ctx[:current_user], permission, model)
                  else
                    model
                  end
          scope.find_by(id: args['id'])
        }
      end
    end
  end
end
