class Api::V1::MessagesController < ApplicationController
  def create
    # check param required, if one missing, auto render Bad Request
    params.require([:text, :sender_id, :receiver_id, :room_flag])

    # check param permitted, if there's one params not permitted, render Bad Request
    permitted = params.permit(:text, :sender_id, :receiver_id, :room_flag, :room_id)
    unless permitted.permitted?
      return render json: {
        message: "The only parameter permitted is text, sender_id, " + 
          "receiver_id, room_flag and room_id"
      }, status: :bad_request
    end

    # create data
    message = nil
    begin
      # transaction atomic activated
      ActiveRecord::Base.transaction do
        # if flag private, create private room 
        # and participant first if room id not provided
        room_id = params[:room_id]
        room_flag = params[:room_flag]
        if room_flag == "private" and not room_id
          room = Room.new({flag: "private"})
          unless room.save
            raise StandardError.new room.errors.full_messages
          end
          room_id = room.id

          participant_sender = Participant.new({
            room_id: room_id,
            user_id: params[:sender_id]
          })
          unless participant_sender.save
            raise StandardError.new participant_sender.errors.full_messages
          end
  
          participant_receiver = Participant.new({
            room_id: room_id,
            user_id: params[:receiver_id]
          })
          unless participant_receiver.save
            raise StandardError.new participant_receiver.errors.full_messages
          end

        # if other then private, room_id become required
        else
          unless room_id
            raise BadRequestError.new "room_id required"
          end
        end

        # create private message
        message = Message.new({
          text: params[:text],
          room_id: room_id,
          user_id: params[:sender_id],
        })
        unless message.save
          raise StandardError.new message.errors.full_messages
        end
      end

    rescue BadRequestError => e
      return render json: {
        message: e
      }, status: :bad_request

    rescue StandardError => e
      return render json: {
        message: e
      }, status: :internal_server_error
    end

    return render json: {
      message: "created successfully!",
      data: message
    }, status: :created
  end

  def index
    puts params
    render json: {
      message: "get all successfully!"
    }, status: :created
  end

  def show
    puts params
    render json: {
      message: "get one successfully!"
    }, status: :created
  end

  def update
    puts params
    render json: {
      message: "update successfully!"
    }, status: :created
  end

  def destroy
    puts params
    render json: {
      message: "delete successfully!"
    }, status: :created
  end
end

# custom exception
class BadRequestError < StandardError
end
