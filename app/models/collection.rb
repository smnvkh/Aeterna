class Collection < ApplicationRecord
  belongs_to :family
  belongs_to :family_member, optional: true

  has_many :collection_memories, dependent: :destroy
  has_many :memories, through: :collection_memories

  delegate :user, to: :family_member, allow_nil: true

  acts_as_taggable_on :categories

  validates :title, :date, presence: true

  before_create :assign_decor_icon

  DECOR_ICONS_PATH = Rails.root.join("app/assets/images/profile/collections")

  private

  def assign_decor_icon
    icons = Dir.children(DECOR_ICONS_PATH).select { |f| f.end_with?(".svg") }
    self.decor_icon = icons.sample
  end
end
