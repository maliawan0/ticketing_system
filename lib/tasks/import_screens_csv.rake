require 'csv'

namespace :import do
  desc "Import screens from screens.csv into the Screen model"
  task screens_csv: :environment do
    filepath = Rails.root.join("screens.csv")

    unless File.exist?(filepath)
      puts "❌ File not found: #{filepath}"
      next
    end

    CSV.foreach(filepath, headers: true) do |row|
      cinema_name   = row["cinema_name"]
      screen_name   = row["screen_name"]
      seat_capacity = row["seat_capacity"]

      cinema = Cinema.find_by(name: cinema_name)

      if cinema
        screen = cinema.screens.find_or_initialize_by(name: screen_name)
        screen.seat_capacity = seat_capacity
        if screen.save
          puts "✅ Created screen '#{screen_name}' for cinema '#{cinema_name}'"
        else
          puts "⚠️ Failed to create screen '#{screen_name}' for cinema '#{cinema_name}': #{screen.errors.full_messages.join(", ")}"
        end
      else
        puts "❌ Cinema not found: #{cinema_name}"
      end
    end

    puts "🎉 Screen import complete!"
  end
end
