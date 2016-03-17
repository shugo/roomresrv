class Room < ActiveRecord::Base
  belongs_to :office
  has_many :reservations
  validates :name, presence: true
  scope :ordered, -> { order("office_id, id") }

  def name_with_office
    "#{name}（#{office.name}）"
  end
end
