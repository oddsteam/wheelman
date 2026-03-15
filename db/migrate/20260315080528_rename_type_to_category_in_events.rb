class RenameTypeToCategoryInEvents < ActiveRecord::Migration[8.1]
  def change
    rename_column :events, :type, :category
  end
end
