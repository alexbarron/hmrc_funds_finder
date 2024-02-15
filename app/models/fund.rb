class Fund < ApplicationRecord
  validates :sub_fund_name, uniqueness: true
  validates :hmrc_share_class_ref_no, uniqueness: true
  validates :isin_no, uniqueness: { allow_nil: true, allow_blank: true }
  validates :cusip_no, uniqueness: { allow_nil: true, allow_blank: true }

  def self.set_openfigi_data
    Fund.where("(ticker IS NULL OR ticker = 'Not Available') AND (cusip_no != '' OR isin_no != '')").in_batches(of: 100) do |batch|
      result = OpenFIGIServices::GetMultipleTickersService.new(batch).call

      # Must convert to hash to use upsert_all
      funds_array = result.funds.map do |fund|
        fund.attributes.symbolize_keys
      end

      Fund.upsert_all(funds_array, 
        record_timestamps: true, 
        update_only: [:ticker, :openfigi_name]
      )
    end
  end
end
