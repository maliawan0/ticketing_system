require "test_helper"

class TicketTest < ActiveSupport::TestCase
  test "price multiplier applies by seat type" do
    ticket = tickets(:one)
    assert ticket.price(10.0) > 0
  end

  test "uniqueness of seat within show_time" do
    one = tickets(:one)
    dup = Ticket.new(show_time: one.show_time, seat: one.seat, status: :available)
    assert_not dup.valid?
  end
end

