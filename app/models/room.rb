class Room < ActiveRecord::Base
  belongs_to :office
  has_many :reservations
  validates :office_id, presence: true
  validates :name, presence: true, uniqueness: { scope: [:office_id] }
  scope :ordered, -> { order("office_id, id") }

  def name_with_office
    "#{name}（#{office.name}）"
  end
end
