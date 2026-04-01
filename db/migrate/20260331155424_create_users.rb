class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :line_user_id, null: false
      t.string :display_name
      t.string :picture_url

      t.timestamps
    end
  end
end
