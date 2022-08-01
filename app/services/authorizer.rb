class Authorizer
  def initialize(user:, action:, entity:, record: nil)
    @user = user
    @role = user.role
    @action = action
    @entity = entity
    @record = record
  end

  def run
    return false unless @role

    @record ? authorized_with_record? : authorized?
  end

  private

  # We delegate to a policy when the permissions
  # need to be checked against a record
  def authorized_with_record?
    return authorized? unless policy_klass

    authorized? && policy_klass.new(@user, @record).send(@action)
  end

  def authorized?
    return false unless permissions
    return true if permissions[:all]
    return false unless permissions[@entity]
    return true if permissions[@entity]&.include?(:all)

    permissions[@entity].include?(@action)
  end

  def permissions
    @permissions ||= Role::ROLE_PERMISSIONS[@role&.name&.to_sym]
  end

  def policy_klass
    @policy_klass ||= constantize_policy_klass
  end

  def constantize_policy_klass
    klass_name = "#{@entity.to_s.singularize.capitalize}Policy"
    return nil unless Kernel.const_defined?(klass_name)

    klass_name.constantize
  end
end
