namespace :populate do
  desc "Populate show_times using Sidekiq job batches"
  task showtimes: :environment do
    require 'faker'

    cinemas = Cinema.all
    movies = Movie.all

    batch_size = 50
    showtimes = []

    cinemas.each do |cinema|
      cinema.screens.each do |screen|
        # Generate 3 time slots per screen
        3.times do
          movie = movies.sample
          start_time = Faker::Time.forward(days: 14, period: :evening)
          end_time = start_time + movie.duration.minutes

          showtimes << {
            'cinema_id' => cinema.id,
            'movie_id' => movie.id,
            'start_time' => start_time.to_s,
            'end_time' => end_time.to_s
          }
        end
      end
    end

    puts "Enqueuing #{showtimes.size} showtimes..."

    showtimes.each_slice(batch_size).with_index do |batch, index|
      CreateShowTimesJob.perform_async(batch)
      puts "✅ Enqueued batch #{index + 1} with #{batch.size} showtimes"
    end
  end

  desc "Reset show_times table and auto-increment counter"
  task reset_showtimes: :environment do
    ShowTime.delete_all
    ActiveRecord::Base.connection.execute('ALTER TABLE show_times AUTO_INCREMENT = 1')
    puts "✅ Show times table reset. Auto-increment counter set to 1."
  end

  desc "Generate seats for all screens"
  task seats: :environment do
    screens = Screen.all
    total_seats_created = 0

    screens.each do |screen|
      puts "Generating seats for #{screen.name} (Capacity: #{screen.seat_capacity})"
      
      # Calculate grid dimensions (approximate square layout)
      grid_size = Math.sqrt(screen.seat_capacity).ceil
      seats_per_row = grid_size
      num_rows = (screen.seat_capacity.to_f / seats_per_row).ceil
      
      seats_created = 0
      
      ('A'.ord..('A'.ord + num_rows - 1)).each do |row_ord|
        row = row_ord.chr
        seats_per_row.times do |col|
          break if seats_created >= screen.seat_capacity
          
          seat_number = "#{row}#{col + 1}"
          column = col + 1
          
          # Determine seat type based on position
          seat_type = if row_ord <= 'A'.ord + 2  # First 3 rows are VIP
                        :vip
                      elsif row_ord <= 'A'.ord + 5  # Next 3 rows are Premium
                        :premium
                      else
                        :standard
                      end
          
          seat = screen.seats.create!(
            seat_number: seat_number,
            seat_type: seat_type,
            row: row,
            column: column
          )
          
          seats_created += 1
        end
      end
      
      total_seats_created += seats_created
      puts "  ✅ Created #{seats_created} seats for #{screen.name}"
    end
    
    puts "\n🎉 Total seats created: #{total_seats_created}"
  end

  desc "Reset seats table and auto-increment counter"
  task reset_seats: :environment do
    Seat.delete_all
    ActiveRecord::Base.connection.execute('ALTER TABLE seats AUTO_INCREMENT = 1')
    puts "✅ Seats table reset. Auto-increment counter set to 1."
  end

  desc "Generate Ticket seat mappings for all show times using background jobs"
  task show_time_seats: :environment do
    show_times = ShowTime.all
    batch_size = 10  # Process 10 show times per job
    
    puts "Enqueuing Ticket seat mapping jobs for #{show_times.count} show times..."
    
    show_times.pluck(:id).each_slice(batch_size).with_index do |batch, index|
      CreateShowTimeSeatsJob.perform_async(batch)
      puts "✅ Enqueued Ticket seat mapping job #{index + 1} for #{batch.size} show times"
    end
    
    puts "\n🎉 All Ticket seat mapping jobs enqueued!"
    puts "💡 Run 'rails populate:show_time_seats_status' to check progress"
  end

  desc "Check Ticket seat mapping progress"
  task show_time_seats_status: :environment do
    total_show_times = ShowTime.count
    show_times_with_mappings = ShowTime.joins(:tickets).distinct.count
    total_mappings = Ticket.count
    
    puts "📊 Ticket seat Mapping Status:"
    puts "  Total ShowTimes: #{total_show_times}"
    puts "  ShowTimes with mappings: #{show_times_with_mappings}"
    puts "  Total seat mappings: #{total_mappings}"
    puts "  Progress: #{(show_times_with_mappings.to_f / total_show_times * 100).round(2)}%"
    
    if show_times_with_mappings < total_show_times
      puts "\n⏳ Still processing... Check back in a few minutes"
    else
      puts "\n✅ All Ticket seat mappings completed!"
    end
  end

  desc "Reset Ticket table and auto-increment counter"
  task reset_show_time_seats: :environment do
    Ticket.delete_all
    ActiveRecord::Base.connection.execute('ALTER TABLE tickets AUTO_INCREMENT = 1')
    puts "✅ Ticket table reset. Auto-increment counter set to 1."
  end

  desc "Clean up expired seat locks"
  task cleanup_locks: :environment do
    expired_locks = Ticket.locked.where('locked_at < ?', 15.minutes.ago)
    count = expired_locks.count
    
    if count > 0
      expired_locks.update_all(
        status: :available,
        locked_at: nil,
        booking_reference: nil
      )
      puts "✅ Unlocked #{count} expired seat locks"
    else
      puts "✅ No expired locks found"
    end
  end
end
  