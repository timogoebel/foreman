Types::QueryType = GraphQL::ObjectType.define do
  name "Query"

  field :model, Types::ModelType, field: Fields::FetchField.build(type: Types::ModelType, model: Model)
  field :models, types[Types::ModelType], field: Fields::PluralField.build(type: Types::ModelType, model: Model)
  field :bookmark, Types::BookmarkType, field: Fields::FetchField.build(type: Types::BookmarkType, model: Bookmark)
  field :bookmarks, types[Types::BookmarkType], field: Fields::PluralField.build(type: Types::BookmarkType, model: Bookmark)
  field :subnet, Types::SubnetType, field: Fields::FetchField.build(type: Types::SubnetType, model: Subnet)
  field :subnets, types[Types::SubnetType], field: Fields::PluralField.build(type: Types::SubnetType, model: Subnet)
end
