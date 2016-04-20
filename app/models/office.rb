class Office < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :rooms
end
