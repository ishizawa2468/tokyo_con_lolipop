class RemoveUnnecessaryColumnsFromPosts < ActiveRecord::Migration[7.1]
  def change
    remove_column :posts, :like_num, :integer
    remove_column :posts, :dislike_num, :integer
    remove_column :posts, :watch_num, :integer
  end
end
