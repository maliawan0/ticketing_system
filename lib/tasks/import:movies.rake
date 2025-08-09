require 'csv'

namespace :import do
  desc "Import movies from CSV"
  task movies: :environment do
    file_path = Rails.root.join('lib', 'assets','seed_data', 'movies.csv')

    puts "📥 Starting movie import from #{file_path}..."

    CSV.foreach(file_path, headers: true) do |row|
      movie = Movie.find_or_initialize_by(title: row['title'])

      movie.assign_attributes(
        category:     row['category'],
        genre:        row['genre'],
        language:     row['language'],
        duration:     row['duration'].to_i,
        rating:       row['rating'].to_f,
        cast:         row['cast'],
        description:  row['description'],
        image_url:    row['image_url']
      )

      if movie.save
        puts "✅ Saved: #{movie.title}"
      else
        puts "❌ Failed: #{movie.title} - #{movie.errors.full_messages.join(', ')}"
      end
    end

    puts "🎬 Movie import complete!"
  end
end
