# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'csv'
require 'bcrypt'

def seed_from_csv(file_name, model_class)
  puts file_name + " will be read"
  # Shift_JISでCSVファイルを読み込み、UTF-8に変換
  begin
    content = File.read(Rails.root.join('db', 'csv', file_name), encoding: 'Shift_JIS:UTF-8')
    puts "File successfully read: #{file_name}"  # ファイルが読み込まれたことを確認するログ
  rescue Encoding::UndefinedConversionError => e
    puts "Encoding error during file read: #{e.message}"  # エンコードエラーが発生した場合のログ
    return
  end
  puts file_name + " have read"

  total_rows = 0
  created_rows = 0
  skipped_rows = 0

  # CSVの内容をパースし、各行を処理
  CSV.parse(content, headers: true).each_with_index do |row, index|
    total_rows += 1
    attributes = row.to_hash
    # puts "Processing row #{index + 1}: #{attributes.inspect}"  # 現在処理中の行をログに出力。デバッグ用

    case model_class.name
    when 'User'
      attributes['password_digest'] = BCrypt::Password.create(attributes.delete('password'))
    when 'Post'
      user = User.find_by(nickname: attributes.delete('user_nickname'))
      attributes['user_id'] = user.id if user
      attributes['poster_name'] = user.nickname.present? ? user.nickname : '匿名コンサルタント'
    when 'Comment'
      user = User.find_by(nickname: attributes.delete('user_nickname'))
      post = Post.find_by(title: attributes.delete('post_title'))
      attributes['user_id'] = user.id if user
      attributes['post_id'] = post.id if post
      attributes['poster_name'] = user.nickname.present? ? user.nickname : '匿名コンサルタント'
    end

    # created_atとupdated_atを設定
    created_at = attributes['created_at']
    if created_at
      attributes['created_at'] = attributes['updated_at'] = Time.zone.parse(created_at)
    end

    begin
      existing_record = model_class.find_by(attributes.except('created_at', 'updated_at'))

      if existing_record
        skipped_rows += 1
        puts "Skipped existing #{model_class.name}: #{attributes.inspect}"
      else
        model_class.create!(attributes)
        created_rows += 1
      end
    rescue => e
      puts "Error processing row #{index + 1}: #{e.message}"
      # puts "Row data: #{attributes.inspect}"
    end
  end

  # 結果を表示
  puts "#{model_class} data seeded:"
  puts "  Total rows processed: #{total_rows}"
  puts "  New records created: #{created_rows}"
  puts "  Existing records skipped: #{skipped_rows}"
end

# Likesの生成
RESET = {
  # 消去
  users: true,
  watchwords: true,
  likes: true,
  posts: true,
  comments: true,
  # そのまま
}

if RESET[:likes]
  puts "Likesのリセット"
  Like.delete_all
end
if RESET[:comments]
  puts "Commentsのリセット"
  Comment.delete_all
end
if RESET[:posts]
  puts "Postsのリセット"
  Post.delete_all
end
if RESET[:users]
  puts "Usersのリセット"
  User.delete_all
end
if RESET[:watchwords]
  puts "Watchwordsのリセット"
  Watchword.delete_all
end


# Likesの生成
def generate_likes
  users = User.all
  posts = Post.all

  # 各ユーザーが50%の確率で各投稿にいいねをする
  users.each do |user|
    posts.each do |post|
      if rand < 0.05 # 5%の確率
        Like.find_or_create_by!(user: user, post: post) do |like|
          like.created_at = like.updated_at = Time.zone.now - rand(7).days
        end
      end
    end
  end

  puts "Likes data generated successfully."
end

# Usersのシード
seed_from_csv('users.csv', User)
# Postsのシード
seed_from_csv('posts.csv', Post)
# Commentsのシード
seed_from_csv('comments.csv', Comment)
generate_likes

puts "Userの総数: #{User.count}"
puts "Postの総数: #{Post.count}"
puts "Commentの総数: #{Comment.count}"
puts "Watchwordの総数: #{Watchword.count}"
