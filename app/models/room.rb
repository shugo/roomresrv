class Room < ActiveRecord::Base
  belongs_to :office
  has_many :reservations
  validates :name, presence: true

  def name_with_office
    "#{name}（#{office.name}）"
  end
end
