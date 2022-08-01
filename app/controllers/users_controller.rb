class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]

  def index
    authorize! :index, :users
    @users = User.all
  end

  def show
    authorize! :show, :users, @user
  end

  def new
    authorize! :create, :users
    @user = User.new
  end

  def edit
    authorize! :update, :users, @user

    @roles = Role.all.map do |role|
      [role.to_s, role.id]
    end
  end

  def create
    authorize! :create, :users
    @user = User.new(user_params)

    if @user.save
      redirect_to user_path(@user), notice: "User was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
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
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role_id)
  end
end
