class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, # :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  belongs_to :family

  has_many :comments, dependent: :destroy

  # Косвенный доступ:
  has_many :memories, through: :family

  has_one :family_member
  has_one :profile
  after_create :create_profile
end
