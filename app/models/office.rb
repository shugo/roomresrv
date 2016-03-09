class Office < ActiveRecord::Base
  validates :name, presence: true
  has_many :rooms
end
