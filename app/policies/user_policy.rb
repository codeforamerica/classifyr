class UserPolicy < ApplicationPolicy
  def show
    @current_user != @record
  end

  def update
    @current_user != @record
  end

  def destroy
    @current_user != @record
  end
end
