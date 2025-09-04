class CreateArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :articles do |t|
      t.string :url
      t.string :title
      t.datetime :published_at
      t.text :body

      t.timestamps
    end
  end
end
