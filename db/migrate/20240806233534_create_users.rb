class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :nickname
      t.string :password_digest
      t.string :watchword
      t.boolean :admin

      t.timestamps
    end
  end
end
