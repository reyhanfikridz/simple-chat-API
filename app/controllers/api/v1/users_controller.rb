class Api::V1::UsersController < ApplicationController
  def create
    # check param required, if one missing, auto render Bad Request
    params.require([:email, :password, :full_name, :phone_number, :address])

    # check param permitted, if there's one params not permitted, render Bad Request
    permitted = params.permit(:email, :password, :full_name, :phone_number, :address)
    unless permitted.permitted?
      return render json: {
        message: "The only parameter permitted is email, " + 
          "password, full_name, phone_number, address"
      }, status: :bad_request
    end

    # create data
    user = nil
    begin
      # transaction atomic activated
      ActiveRecord::Base.transaction do
        # create user
        user = User.new({
          email: params[:email],
          password: params[:password],
          full_name: params[:full_name],
          phone_number: params[:phone_number],
          address: params[:address],
        })
        unless user.save
          raise StandardError.new user.errors.full_messages
        end
      end

    rescue StandardError => e
      return render json: {
        message: e
      }, status: :internal_server_error
    end

    return render json: {
      message: "User created successfully!",
      data: user
    }, status: :created
  end
end
