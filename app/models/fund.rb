class Fund < ApplicationRecord
  validates :sub_fund_name, uniqueness: true
  validates :hmrc_share_class_ref_no, uniqueness: true
  validates :isin_no, uniqueness: { allow_nil: true, allow_blank: true }
  validates :cusip_no, uniqueness: { allow_nil: true, allow_blank: true }
end
