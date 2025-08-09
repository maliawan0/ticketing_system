# lib/tasks/import_data.rake
require 'csv'

namespace :import do

  desc "Import locations from CSV"
  task locations: :environment do
    puts "🚀 Importing locations..."
    CSV.foreach(Rails.root.join("lib/assets/seed_data/locations.csv"), headers: true) do |row|
      name = row['name'].strip
      Location.find_or_create_by!(name: name)
    end
    puts "✅ Locations imported successfully."
  end

  desc "Import areas from CSV"
  task areas: :environment do
    puts "🚀 Importing areas..."
    CSV.foreach(Rails.root.join("lib/assets/seed_data/areas.csv"), headers: true) do |row|
      name = row['name'].strip
      location_name = row['location_name'].strip

      location = Location.find_by("LOWER(name) = ?", location_name.downcase)

      if location.nil?
        puts "⚠️ Location not found for area: #{name} (location_name: '#{location_name}')"
        next
      end

      Area.find_or_create_by!(name: name, location_id: location.id)
    end
    puts "✅ Areas imported successfully."
  end

  desc "Import cinemas from CSV"
  task cinemas: :environment do
    puts "🚀 Importing cinemas..."
    CSV.foreach(Rails.root.join("lib/assets/seed_data/cinemas.csv"), headers: true) do |row|
      name = row['name'].strip
      area_name = row['area_name'].strip

      area = Area.find_by("LOWER(name) = ?", area_name.downcase)

      if area.nil?
        puts "⚠️ Area not found for cinema: #{name} (area_name: '#{area_name}')"
        next
      end

      Cinema.find_or_create_by!(name: name, area_id: area.id)
    end
    puts "✅ Cinemas imported successfully."
  end

end
