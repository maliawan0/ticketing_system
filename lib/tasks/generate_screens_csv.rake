require 'csv'

namespace :generate do
  desc "Generate screens.csv with 3 screens per cinema using fixed seat capacities"
  task screens_csv: :environment do
    filepath = Rails.root.join("screens.csv")

    CSV.open(filepath, "w") do |csv|
      csv << ["cinema_name", "screen_name", "seat_capacity"]

      Cinema.find_each do |cinema|
        csv << [cinema.name, "Screen 1", 100]
        csv << [cinema.name, "Screen 2", 150]
        csv << [cinema.name, "Screen 3", 200]
      end
    end

    puts "✅ Generated screens.csv with fixed capacities at: #{filepath}"
  end
end
