class Api::V1::RoomsController < ApplicationController
  def create
    # check param required, if one missing, auto render Bad Request
    params.require([:name, :flag])

    # check param permitted, if there's one params not permitted, render Bad Request
    permitted = params.permit(:name, :flag)
    unless permitted.permitted?
      return render json: {
        message: "The only parameter permitted is name and flag"
      }, status: :bad_request
    end

    # create data
    room = nil
    begin
      # transaction atomic activated
      ActiveRecord::Base.transaction do
        # create room
        room = Room.new({
          name: params[:name],
          flag: params[:flag],
        })
        unless room.save
          raise StandardError.new room.errors.full_messages
        end
      end

    rescue StandardError => e
      return render json: {
        message: e
      }, status: :internal_server_error
    end

    return render json: {
      message: "Room created successfully!",
      data: room
    }, status: :created
  end

  def index
    # check param required, if one missing, auto render Bad Request
    params.require([:user_id])

    # check param permitted, if there's one params not permitted, render Bad Request
    permitted = params.permit(:user_id)
    unless permitted.permitted?
      return render json: {
        message: "The only parameter permitted is user_id"
      }, status: :bad_request
    end

    # get messages by user_id order by created_at
    messages = Message \
      .joins(:room, :user) \
      .where(user_id: params[:user_id]) \
      .order(created_at: :desc)

    # get rooms from messages
    room_id_duplicates = []
    rooms = []
    for message in messages do
      if room_id_duplicates.include? message.room_id
        next
      end

      room_id_duplicates.append(message.room_id)

      room = {
        room: message.room,
        last_message: message,
        user_info: message.user,
      }
      rooms.append(room)
    end

    return render json: rooms, status: :ok
  end
end
