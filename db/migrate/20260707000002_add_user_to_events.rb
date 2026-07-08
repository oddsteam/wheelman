class AddUserToEvents < ActiveRecord::Migration[8.1]
  def change
    # nullable: existing events have no creator
    add_reference :events, :user, foreign_key: true, null: true
  end
end
