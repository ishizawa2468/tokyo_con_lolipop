class CreateWatchwords < ActiveRecord::Migration[7.1]
  def change
    create_table :watchwords do |t|
      t.string :word

      t.timestamps
    end
  end
end
