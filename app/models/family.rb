class Family < ApplicationRecord
  has_many :users
  has_many :memories, dependent: :destroy
  has_many :family_members

  before_create :generate_invite_code

  private

  def generate_invite_code
    self.invite_code = loop do
      code = SecureRandom.alphanumeric(6).upcase
      break code unless Family.exists?(invite_code: code)
    end
  end
end
