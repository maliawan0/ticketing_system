class Location < ApplicationRecord
    has_many :areas, dependent: :destroy

    validates :name, presence: true , uniqueness: { case_sensitive: false} , length: {minimum: 3}
end
