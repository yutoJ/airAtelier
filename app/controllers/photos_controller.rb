class PhotosController < ApplicationController
  def create
    @room = Room.find(param[:room_id])

    if params[:images]
      params[:images].each do |img|
        @room.photos.create(image: img)
      end
    end
    @photos = @room.photos
    redirect_back(fallback_location: request.referer, notice: "Saved...")
  end

end
