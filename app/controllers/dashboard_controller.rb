# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @user = current_user
  end
end
