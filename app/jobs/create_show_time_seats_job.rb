class CreateShowTimeSeatsJob
  include Sidekiq::Job

  def perform(show_time_ids)
    show_times = ShowTime.where(id: show_time_ids)
    total_mappings_created = 0

    show_times.each do |show_time|
      Rails.logger.info "Creating ticket seat mappings for ShowTime #{show_time.id}: #{show_time.display_info}"
      
      mappings_created = 0
      
      # Create Ticket mappings for all seats in the screen
      show_time.screen.seats.find_each do |seat|
        Ticket.create!(
          show_time: show_time,
          seat: seat,
          status: :available
        )
        mappings_created += 1
      end
      
      total_mappings_created += mappings_created
      Rails.logger.info "✅ Created #{mappings_created} ticket seat mappings for ShowTime #{show_time.id}"
    end

    Rails.logger.info "🎉 Total Ticket seat mappings created: #{total_mappings_created}"
  rescue => e
    Rails.logger.error "Failed to create Ticket seat mappings: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end
end
