class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  before_action :resume_session, only: %i[new create]

  def new
    render Components::Views::Registrations::NewView.new(
      user: User.new,
      email_address: params[:email_address]
    )
  end

  def create
    @user = User.new(user_params)
    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: "You've successfully signed up."
    else
      render Components::Views::Registrations::NewView.new(
        user: @user,
        email_address: params[:email_address]
      )
    end
  end

  private

  def user_params
    params.expect(user: [ :email_address, :password, :password_confirmation ])
  end
end
