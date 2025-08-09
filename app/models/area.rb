class Area < ApplicationRecord
  belongs_to :location
  has_many :cinemas, dependent: :destroy

  validates :name, presence: true , uniqueness: { scope: :location_id , case_sensitive: false}
  
end
