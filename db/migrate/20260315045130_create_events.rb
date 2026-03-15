class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :name
      t.json :activity_type
      t.string :type
      t.string :description
      t.string :location_description
      t.string :location_link
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
