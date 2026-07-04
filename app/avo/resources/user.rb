class Avo::Resources::User < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :line_user_id, as: :text
    field :display_name, as: :text
    field :picture_url, as: :text
    field :email, as: :text
    field :admin, as: :boolean
    field :password, as: :password, only_on: :forms
  end
end
