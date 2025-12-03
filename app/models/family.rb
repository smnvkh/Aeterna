# «семейный аккаунт», к которому привязаны пользователи
class Family < ApplicationRecord
  has_many :users
  has_many :memories, through: :users
  has_many :family_members
end
