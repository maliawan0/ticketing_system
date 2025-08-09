class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: [:show]
  # load_and_authorize_resource

  def index
    @bookings = current_user.bookings.includes(:tickets)
    render json: @bookings.to_json(include: :tickets)
  end

  def show
    render json: @booking.to_json(include: {
      tickets: {
        include: {
          seat: {
            include: {
              screen: {
                include: {
                  cinema: {
                    include: :area
                  }
                }
              }
            }
          }
        }
      }
    })
  end

  # def create
  #   binding.pry

  #   ticket_ids = params[:ticket_ids] || []
  #   tickets = Ticket.lock.where(id: ticket_ids, status: :locked)

  #   if tickets.size != ticket_ids.size
  #     render json: { error: "Some tickets are no longer available." }, status: :unprocessable_entity
  #     returntickets = Ticketb.where(id: ticket_ids, status: :locked)
  #   end

  #   if tickets.map(&:show_time_id).uniq.size > 1
  #     render json: { error: "All selected tickets must belong to the same show time." }, status: :unprocessable_entity
  #     return
  #   end

  #   total_price = tickets.sum(&:price)

  #   begin
  #     ActiveRecord::Base.transaction do
  #       booking = Booking.create!(
  #         user: current_user,
  #         bookable: tickets.first.show_time,
  #         booking_reference: SecureRandom.hex(8),
  #         total_price: total_price,
  #         status: :confirmed
  #       )

  #       tickets.each do |ticket|
  #         ticket.update!(
  #           status: :booked,
  #           booking_id: booking.id,
  #           booking_reference: booking.booking_reference
  #         )
  #       end

  #       render json: {
  #         message: "Booking confirmed!",
  #         booking_id: booking.id,
  #         booking_reference: booking.booking_reference,
  #         total_price: total_price
  #       }, status: :created
  #     end
  #   rescue ActiveRecord::RecordInvalid => e
  #     render json: { error: "Booking failed: #{e.message}" }, status: :unprocessable_entity
  #   end
  # end


  def create
    ticket_ids = Array(params[:ticket_ids]).map(&:to_i)
    tickets = Ticket.lock.where(id: ticket_ids, status: :locked)
  
    if tickets.size != ticket_ids.size
      render json: { error: "Some tickets are no longer available." }, status: :unprocessable_entity
      return
    end
  
    if tickets.map(&:show_time_id).uniq.size > 1
      render json: { error: "All selected tickets must belong to the same show time." }, status: :unprocessable_entity
      return
    end
  
    total_price = tickets.sum { |t| t.price }
  
    begin
      ActiveRecord::Base.transaction do
        booking = Booking.create!(
          user: current_user,
          bookable: tickets.first.show_time,
          total_price: total_price,
          status: :confirmed
        )
  
        tickets.each do |ticket|
          ticket.update!(
            status: :booked,
            booking_id: booking.id,
            booking_reference: booking.booking_reference
          )
        end
  
        render json: {
          message: "Booking confirmed!",
          booking_id: booking.id,
          booking_reference: booking.booking_reference,
          total_price: total_price
        }, status: :created
      end
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: "Booking failed: #{e.message}" }, status: :unprocessable_entity
    end
  end

  private

  def set_booking
    @booking = current_user.bookings.find(params[:id])
  end
end
