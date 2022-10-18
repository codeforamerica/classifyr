# frozen_string_literal: true

# This policy focuses on preventing users from accessing, updating, or
# destroying their user records.
#
# It might seem confusing since users can actually update their own data, but
# this policy is actually only used in the UsersController which provides a way
# for administrators to check, update, or destroy users. It was implemented this
# way to prevent an administrator from accidentally changing their role and
# losing permissions.
#
# In order to update their own records, administrators will need to use the "My
# Profile" page instead.
#
# @see Admin::UsersController
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
