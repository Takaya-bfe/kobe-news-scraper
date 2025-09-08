class AddSessionIdToArticles < ActiveRecord::Migration[8.0]
  def change
    add_column :articles, :session_id, :string
  end
end
