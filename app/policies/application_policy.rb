class ApplicationPolicy
  def initialize(user, record)
    @current_user = user
    @role = user.role
    @record = record
  end

  def show
    false
  end

  def update
    false
  end

  def destroy
    false
  end
end
