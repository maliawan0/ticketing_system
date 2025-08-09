class CreateShowTimesJob
  include Sidekiq::Job

  def perform(batch)
    parsed_batch = batch.map do |entry|
      # Get a random screen from the cinema
      cinema = Cinema.find(entry['cinema_id'])
      screen = cinema.screens.sample
      
      {
        movie_id: entry['movie_id'],
        screen_id: screen.id,
        start_time: Time.parse(entry['start_time']),
        end_time: Time.parse(entry['end_time']),
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    begin
      result = ShowTime.insert_all(parsed_batch)
      Rails.logger.info "Successfully inserted #{result.count} show times"
      
      # Get the IDs of the newly created show times
      new_show_time_ids = ShowTime.where(
        movie_id: parsed_batch.map { |b| b[:movie_id] },
        screen_id: parsed_batch.map { |b| b[:screen_id] },
        start_time: parsed_batch.map { |b| b[:start_time] }
      ).pluck(:id)
      
      # Enqueue job to create ShowTimeSeat mappings for these show times
      if new_show_time_ids.any?
        CreateShowTimeSeatsJob.perform_async(new_show_time_ids)
        Rails.logger.info "Enqueued ShowTimeSeat mapping job for #{new_show_time_ids.count} show times"
      end
      
    rescue => e
      Rails.logger.error "Failed to insert show times: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise e
    end
  end
end
  