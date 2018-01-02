Types::BookmarkType = GraphQL::ObjectType.define do
  name 'Bookmark'
  description 'A Bookmark'

  backed_by_model :bookmark do
    attr :name
    attr :controller
    attr :public
    # TODO: belongs to owner
  end
end
