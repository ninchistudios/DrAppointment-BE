class Api::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    @user = User.find_by(
      phone_number: params[:user][:phone_number]
    )

    account_sid = ENV["twilio_account_sid"]
    auth_token = ENV["twilio_auth_token"]
    from = ENV["twilio_phone_number"]

    if @user
      message = "Please enter verification code #{@user.authy_id}"
      to = "1 #{@user.phone_number}"
      @client = Twilio::REST::Client.new(account_sid, auth_token)
      @client.account.messages.create({
          :to => to,
          :from => from,
          :body => message
      })
      render json: @user, status: 200
    else
      @user = User.new(user_params)
      @patient = Patient.new({
        first_name: params[:user][:first_name],
        last_name: params[:user][:last_name]
        })

      if @user.save
        @user.patients.push(@patient)
        message = "Please enter verification code #{@user.authy_id}"
        to = "1 #{@user.phone_number}"
        @client = Twilio::REST::Client.new(account_sid, auth_token)
        @client.account.messages.create({
            :to => to,
            :from => from,
            :body => message
        })
        render json: @user, status: 200
      else
        render json: @user.errors.full_messages, status: 422
      end
    end
  end

  def show
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :country_code, :phone_number)
  end
end
