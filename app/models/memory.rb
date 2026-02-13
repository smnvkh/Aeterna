class Memory < ApplicationRecord
  belongs_to :family
  belongs_to :family_member

  has_many :comments, as: :commentable, dependent: :destroy

  mount_uploader :image, MemoryImageUploader
  acts_as_taggable_on :tags
  acts_as_taggable_on :categories

  validates :title, :image, :date, presence: true

  def as_json
    {
      id: id,
      body: body,
      date: date,
      family_member: family_member.to_s,
      image_url: image.url
    }
  end
end
