class Room < ApplicationRecord
  belongs_to :office
  has_many :reservations
  validates :name, presence: true, uniqueness: { scope: [:office_id] }
  scope :ordered, -> { order("office_id, id") }

  def name_with_office
    if office.nil?
      name
    else
      "#{name}（#{office.name}）"
    end
  end
end
