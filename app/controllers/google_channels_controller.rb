class GoogleChannelsController < ApplicationController
  # POST /rooms/:room_id/google_channels
  def create
    load_room
    @room.sync(channel_params[:calendar_id])

    redirect_to @room
  end

  private

  def load_room
    @room = Room.find(params[:room_id])
  end

  def channel_params
    params.require(:google_channel).permit(:calendar_id)
  end
end
