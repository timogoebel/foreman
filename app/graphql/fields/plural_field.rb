module Fields
  class PluralField
    def self.build(model:, type:)
      return_type = type
      GraphQL::Field.define do
        type(return_type)
        description("Find all #{model.name.pluralize}")
        argument(:search, types.String, 'Search query')
        argument(:order, types.String, 'Search query') # Possibly an enum
        resolve ->(obj, args, ctx) {
          scope = if model.respond_to?(:authorized)
                    permission = model.permission_name(:view)
                    model.authorized_as(ctx[:current_user], permission, model)
                  else
                    model.all
                  end
          scope = scope.search_for(args['search'], :order => args['order']) if args['search']
          scope
        }
      end
    end
  end
end
