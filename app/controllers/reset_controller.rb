class ResetController < ApplicationController
  def create
    AccountService.reset_accounts
    head :ok
  end
end