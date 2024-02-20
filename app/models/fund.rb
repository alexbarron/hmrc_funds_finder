class Fund < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_by_ticker, against: :ticker
  pg_search_scope :search_by_name_and_ticker, against: [:parent_fund, :sub_fund_name, :ticker, :openfigi_name]

  validates :sub_fund_name, uniqueness: true
  validates :hmrc_share_class_ref_no, uniqueness: true
  validates :isin_no, uniqueness: { allow_nil: true, allow_blank: true }
  validates :cusip_no, uniqueness: { allow_nil: true, allow_blank: true }

  scope :actively_reporting, -> { where(ceased_at: nil) }

  def self.set_openfigi_data
    Fund.where(ceased_at: nil).where("(ticker IS NULL OR ticker = 'Not Available') AND (cusip_no != '' OR isin_no != '')").in_batches(of: 100) do |batch|
      result = OpenFIGIServices::GetMultipleTickersService.new(batch).call

      # Must convert to hash to use upsert_all
      funds_array = result.funds.map do |fund|
        fund.attributes.symbolize_keys
      end

      Fund.upsert_all(funds_array, 
        record_timestamps: true, 
        update_only: [:ticker, :openfigi_name]
      )

      sleep(3)
    end
  end
end
