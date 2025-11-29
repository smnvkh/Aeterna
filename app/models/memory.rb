class Memory < ApplicationRecord
  validates :title, presence: true, length: { minimum: 5 }
  has_many :comments, dependent: :destroy
  mount_uploader :image, MemoryImageUploader
  validates :image, presence: true
  validates :date, presence: true

  belongs_to :family_member
  belongs_to :user
end
