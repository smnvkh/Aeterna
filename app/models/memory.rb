class Memory < ApplicationRecord
  validates :title, presence: true, length: { minimum: 5 }
  has_many :comments, dependent: :destroy
  mount_uploader :image, MemoryImageUploader

  belongs_to :family_member, optional: true
end
