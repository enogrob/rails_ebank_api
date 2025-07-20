class BalancesController < ApplicationController
  def show
    result = AccountService.get_balance(params[:account_id])
    render json: result[:body], status: result[:status]
  end
end