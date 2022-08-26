class UsersController < ApplicationController
  before_action :set_user, only: %i[edit update destroy]
  before_action :set_roles, only: %i[edit update]
  before_action :set_breadcrumbs

  def index
    authorize! :index, :users
    @users = User.includes(:role).order(created_at: :desc).page(params[:page] || 1).per(10)
  end

  def edit
    authorize! :update, :users, @user
    add_breadcrumb("Edit #{@user.email}", edit_user_path(@user))
  end

  def update
    authorize! :update, :users, @user

    if @user.update(user_params)
      redirect_to users_url, notice: "User was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! :destroy, :users, @user

    @user.destroy

    redirect_to users_url, notice: "User was successfully destroyed."
  end

  private

  def set_user
    @user = User.find_by!(slug: params[:slug])
  end

  def set_roles
    @roles = Role.all.map do |role|
      [role.to_s, role.id]
    end
  end

  def user_params
    params.require(:user).permit(:email, :role_id)
  end

  def set_breadcrumbs
    add_breadcrumb("Users", users_path)
  end
end
