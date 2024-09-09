class CreateAccessLogInfos < ActiveRecord::Migration[7.1]
  def change
    create_table :access_log_infos do |t|
      t.string :user_nickname
      t.string :ip
      t.string :url
      t.string :referer
      t.string :user_agent
      t.string :method
      t.integer :status

      t.timestamps
    end
  end
end
