class SettingsController < ApplicationController
  before_action :find_setting, only: [:edit, :update]

  def edit
    @setting = User.find(current_user.id).setting
  end

  def update
    @setting = User.find(current_user.id).setting
    if @setting.update(setting_params)
      flash[:notice] = "Saved..."
    else
      flash[:alert] = "Cannot save..."
    end
    render 'edit'
  end

  private
    def setting_params
      params.require(:setting).permit(:enable_sms, :enable_email)
    end

    def find_setting
      @setting = User.find(current_user.id).setting
    end
end