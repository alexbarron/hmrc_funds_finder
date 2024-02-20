class FundsController < ApplicationController
  def index
    @funds = Fund.actively_reporting.limit(500)
  end

  def show
    @fund = Fund.find(params[:id])
  end
end
