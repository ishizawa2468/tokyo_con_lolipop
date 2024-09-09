class User < ApplicationRecord
  has_secure_password

  has_many :posts, dependent: :nullify
  has_many :comments, dependent: :nullify
  has_many :likes
  has_many :liked_posts, through: :likes, source: :post

  validates :nickname, presence: true, uniqueness: true
  validates :watchword, presence: true
end
