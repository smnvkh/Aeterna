class Memory < ApplicationRecord
  belongs_to :family
  belongs_to :family_member

  has_many :comments, dependent: :destroy

  mount_uploader :image, MemoryImageUploader

  validates :title, :image, :date, presence: true
end
