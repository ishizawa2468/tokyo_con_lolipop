class RenameAnonymousNameToPosterName < ActiveRecord::Migration[7.1]
  def change
    rename_column :posts, :anonymous_name, :poster_name
    rename_column :comments, :anonymous_name, :poster_name
  end
end
