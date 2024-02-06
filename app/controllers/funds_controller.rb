class FundsController < ApplicationController
  def index
    @funds = Fund.all
  end

  def show
    @fund = Fund.find(params[:id])
  end
end
