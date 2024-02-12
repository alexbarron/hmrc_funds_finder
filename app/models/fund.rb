class Fund < ApplicationRecord
  validates :sub_fund_name, uniqueness: true
  validates :hmrc_share_class_ref_no, uniqueness: true
  validates :isin_no, uniqueness: { allow_nil: true, allow_blank: true }
  validates :cusip_no, uniqueness: { allow_nil: true, allow_blank: true }

  def self.set_tickers
    Fund.in_batches(of: 25) do |batch|
      result = OpenFIGIServices::GetMultipleTickersService.new(batch).call
      
      # Must convert to hash to use upsert_all
      funds_array = result.funds.map do |fund|
        
        puts fund.ticker
        fund.attributes.symbolize_keys
      end

      Fund.upsert_all(funds_array, 
        record_timestamps: true, 
        update_only: [:ticker]
      )
    end
  end
end
