class EventsController < ApplicationController
  def create
    result = AccountService.process_event(params)
    render json: result[:body], status: result[:status]
  end
end