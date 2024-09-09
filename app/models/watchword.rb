class Watchword < ApplicationRecord
  validates :word, presence: true, uniqueness: true
end
