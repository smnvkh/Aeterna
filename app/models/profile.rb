class Profile < ApplicationRecord
  belongs_to :user
  has_one_attached :avatar
  validates :name, presence: true

  after_create :update_family_name

  private

  def update_family_name
    family = user.family
    return unless family

    last_name = name.to_s.split.last
    family.update(name: "Семья #{last_name}") if last_name.present?

    user.family_member&.update(name: name)
  end
end
