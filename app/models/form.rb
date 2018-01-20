class Form < ApplicationRecord
  extend FriendlyId
  belongs_to :user

  friendly_id :title, use: :slugged
end
