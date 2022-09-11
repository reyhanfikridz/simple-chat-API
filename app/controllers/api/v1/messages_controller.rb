class Api::V1::MessagesController < ApplicationController
  def create
    # check param required, if one missing, auto render Bad Request
    params.require([:text, :sender_id, :room_flag])

    # check param permitted, if there's one params not permitted, render Bad Request
    permitted = params.permit(:text, :sender_id, :room_flag, :receiver_id, :room_id)
    unless permitted.permitted?
      return render json: {
        message: "The only parameter permitted is text, sender_id, " + 
          "room_flag, receiver_id and room_id"
      }, status: :bad_request
    end

    # check room flag, 
    # if it's private, receiver_id become required
    # if it's not private, room_id become required
    if params[:room_flag] == "private" and not params[:receiver_id]
      return render json: {
        message: "Params 'receiver_id' required"
      }, status: :bad_request
    elsif params[:room_flag] != "private" and not params[:room_id]
      return render json: {
        message: "Params 'room_id' required"
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
        if params[:room_flag] == "private" and not room_id
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
        end

        # create message
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
      message: "Message created successfully!",
      data: message
    }, status: :created
  end

  def index
    # check param required, if one missing, auto render Bad Request
    params.require([:room_id])

    # check param permitted, if there's one params not permitted, render Bad Request
    permitted = params.permit(:room_id)
    unless permitted.permitted?
      return render json: {
        message: "The only parameter permitted is room_id"
      }, status: :bad_request
    end

    # get messages
    messages = Message.all.where(room_id: params[:room_id]).order(created_at: :asc)
    return render json: messages, status: :ok
  end
end

# custom exception
class BadRequestError < StandardError
end
