class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :poster_name, presence: true
  validates :content, presence: true

  def edited?
    created_at != updated_at
  end

end
