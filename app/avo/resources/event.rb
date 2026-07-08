class Avo::Resources::Event < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :name, as: :text
    field :activity_type, as: :code
    field :category, as: :text
    field :description, as: :textarea
    field :location_description, as: :text
    field :location_link, as: :text
    field :start_date, as: :date
    field :end_date, as: :date
    field :photo, as: :file
    field :user, as: :belongs_to, name: "Creator"
    field :participants_count, as: :text, only_on: :index do
      record.participants.size
    end
  end
end
