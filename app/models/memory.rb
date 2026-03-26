class Memory < ApplicationRecord
  belongs_to :family
  belongs_to :family_member
  has_many :comments, as: :commentable, dependent: :destroy

  delegate :user, to: :family_member, allow_nil: true

  mount_uploader :image, MemoryImageUploader
  acts_as_taggable_on :tags
  acts_as_taggable_on :categories

  validates :title, :date, presence: true
  validate :body_or_image_present

  private

  def body_or_image_present
    if body.blank? && image.blank?
      errors.add(:base, "Нужно указать текст или загрузить изображение")
    end
  end

  # def as_json
  #   {
  #     id: id,
  #     body: body,
  #     date: date,
  #     family_member: family_member.to_s,
  #     image_url: image.url
  #   }
  # end
end
