class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: [:show, :edit, :update, :destroy]

  def index
    load_room
    @bookings = @room.bookings
  end

  def show
  end

  def new
    load_room
    @booking = @room.bookings.build
  end

  def edit
  end

  def create
    load_room
    @booking = @room.bookings.build(booking_params)

    respond_to do |format|
      if @booking.save
        format.html { redirect_to [@room, @booking], notice: 'Booking was successfully created.' }
        format.json { render :show, status: :created, location: @booking }
      else
        format.html { render :new }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @booking.update(booking_params)
        format.html { redirect_to [@room, @booking], notice: 'Booking was successfully updated.' }
        format.json { render :show, status: :ok, location: @booking }
      else
        format.html { render :edit }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @booking.destroy
    respond_to do |format|
      format.html { redirect_to room_bookings_url(@room), notice: 'Booking was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def load_room
    @room = current_user.rooms.find(params[:room_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_booking
    load_room
    @booking = @room.bookings.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def booking_params
    params.require(:booking).permit(:start_at, :end_at)
  end
end
