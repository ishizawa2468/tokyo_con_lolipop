class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.integer :like_num
      t.integer :dislike_num
      t.integer :watch_num

      t.timestamps
    end
  end
end
