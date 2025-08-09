class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.persisted?
      # Authenticated users
      can :create, Booking
      can :manage, Booking, user_id: user.id     # manage = read + update + destroy
    else
      # Guests (not logged in)
      # Allow reading public resources like movies, showtimes, etc.
      can :read, Movie
      can :read, ShowTime
      can :read, Cinema
      can :read, Location
      can :read, Area
    end
  end
end
