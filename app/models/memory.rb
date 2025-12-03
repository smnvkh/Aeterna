class Memory < ApplicationRecord
  belongs_to :user
  belongs_to :family_member

  has_many :comments, dependent: :destroy

  mount_uploader :image, MemoryImageUploader

  validates :title, presence: true
  validates :image, presence: true
  validates :date, presence: true

  has_one :family, through: :user
end
