class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reservation, only: [:approve, :decline]

  def create
    room = Room.find(params[:room_id])

    if current_user == room.user
      flash[:alert] = "You cannot book your own property!"
    else
      start_date = Date.parse(reservation_params[:start_date])
      end_date = Date.parse(reservation_params[:end_date])
      days = (end_date - start_date).to_i + 1

      @reservation = current_user.reservations.build(reservation_params)
      @reservation.room = room
      #TODO Is it in need? I refer the price from room. Is it for when room price is changed ?
      @reservation.price = room.price
      @reservation.total = room.price * days

      if @reservation.save
        if room.Request?
          flash[:notice] = "Request sent successfully!"
        else
          @reservation.Approved!
          flash[:notice] = "Reservation created successfully! "
        end
      else
        flash[:alert] = "Cannot make a reservation!"
      end

    end
    redirect_to room
  end

  def your_trips
    @trips = current_user.reservations.order(start_date: :asc)
  end

  def your_reservations
    @rooms = current_user.rooms
  end

  def approve
      @reservation.Approved!
      ReservationMailer.send_email_to_guest(@reservation.user).deliver
      redirect_to your_reservations_path
  end

  def decline
    @reservation.Declined!
    redirect_to your_reservations_path
  end

  private
  def set_reservation
    @reservation =Reservation.find(params[:id])
  end

  def reservation_params
    params.require(:reservation).permit(:start_date, :end_date)
  end

  def charge(room, reservation)
    if !reservation.user.strip_id.blank?
      customer = Stripe::Customer.retrieve(reservation.user.stripe_id)
      charge = Stripe::charge.create(
        :customer => customer.id,
        :amount => reservation.total * 100,
        :description => room.listing_name,
        :currency => "usd"
      )

      if charge
        reservation.approved!
        ReservationMailer.send_email_to_guest(reservation.user, room).deliver_later
        flash[:notice] = "Reservation created successfully!"
      else
        reservation.declined!
        flash[:alert] = "Cannot charge with this payment method!"
      end
    end
  rescue Stripe::CardError => e
    reservation.declined!
    flash[:alert] = e.message
  end

end
