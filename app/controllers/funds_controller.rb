class FundsController < ApplicationController
  def index
    puts params
    if params[:query] && params[:ticker_only]
      @funds = Fund.search_by_ticker(params[:query])
    elsif params[:query]
      @funds = Fund.search_by_name_and_ticker(params[:query])
    end
  end

  def show
    @fund = Fund.find(params[:id])
  end
end
