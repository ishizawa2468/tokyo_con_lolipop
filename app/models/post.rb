class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user

  has_one_attached :image

  validates :title, presence: true
  validates :content, presence: true
  validates :poster_name, presence: true

  validates :image,
            content_type: ['image/png', 'image/jpg', 'image/jpeg', 'image/heic', 'image/gif'],
            size: { less_than: 5.megabytes ,
                    message: 'is too large. Maximum size allowed is 5MB.' }
  after_commit :resize_image, on: [:create]
  before_save :convert_heic_to_jpeg

  def edited?
    created_at != updated_at
  end

  def liked_by?(user)
    likes.exists?(user_id: user.id)
  end

  def toggle_like(user)
    if liked_by?(user)
      likes.find_by(user_id: user.id).destroy
      false
    else
      likes.create(user_id: user.id)
      true
    end
  end

  def likes_count
    likes.count
  end

  # ransackで検索可能な属性を定義
  def self.ransackable_attributes(auth_object = nil)
    ["title", "content"]
  end

  # ransackで検索可能な関連を定義
  def self.ransackable_associations(auth_object = nil)
    ["comments", "user"]
  end

  private

  def resize_image
    return unless image.attached?

    image.variant(resize_to_limit: [400, 400]).processed
  rescue ActiveStorage::FileNotFoundError
    Rails.logger.error "ActiveStorage::FileNotFoundError: The file for post #{id} was not found."
  end

  def convert_heic_to_jpeg
    return unless image.attached? && image.content_type == 'image/heic'

    heic_image = MiniMagick::Image.read(image.download)
    heic_image.format 'jpg'
    image.attach(io: StringIO.new(heic_image.to_blob), filename: "#{image.filename.base}.jpg", content_type: 'image/jpeg')
  end
end
