class Comment < ApplicationRecord
  belongs_to :memory
  belongs_to :user
end
