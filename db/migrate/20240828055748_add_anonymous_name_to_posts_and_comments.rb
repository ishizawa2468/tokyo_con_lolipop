class AddAnonymousNameToPostsAndComments < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :anonymous_name, :string
    add_column :comments, :anonymous_name, :string
  end
end
