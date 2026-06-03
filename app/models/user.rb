class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  belongs_to :family, optional: true
  enum :role, { member: 0, owner: 1 }

  has_many :comments, dependent: :destroy

  # Косвенный доступ:
  has_many :memories, through: :family

  has_one :family_member
  has_one :profile
  after_create :setup_new_user

  private

  def setup_new_user
    # Если семья не назначена — создать новую
    unless family
      new_family = Family.create!(name: "Моя семья")
      update_columns(family_id: new_family.id)
    end
  end

  delegate :avatar, to: :profile, allow_nil: true
end
