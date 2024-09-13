class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :poster_name, presence: true
  validates :content, presence: true

  def edited?
    created_at != updated_at
  end

  # ransackで検索可能な属性を定義
  def self.ransackable_attributes(auth_object = nil)
    ["content", "created_at", "updated_at", "post_id", "user_id"]
  end
end
