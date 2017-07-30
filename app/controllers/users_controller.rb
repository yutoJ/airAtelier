class UsersController < ApplicationController
  has_many :rooms
  def show
    @user = User.find(params[:id])
  end
end
