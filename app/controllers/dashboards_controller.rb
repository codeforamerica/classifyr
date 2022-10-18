# frozen_string_literal: true

# Rails controller for the main dashboard.
class DashboardsController < ApplicationController
  before_action :set_breadcrumbs

  def index
    authorize! :index, :dashboard
  end

  def show
    authorize! :show, :dashboard
  end

  private

  def set_breadcrumbs
    add_breadcrumb('Dashboard', dashboards_path)
  end
end
