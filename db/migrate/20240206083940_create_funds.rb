class CreateFunds < ActiveRecord::Migration[7.0]
  def change
    create_table :funds do |t|
      t.string :letter_group
      t.string :reporting_fund_ref
      t.string :parent_fund
      t.string :hmrc_share_class_ref_no
      t.string :sub_fund_name
      t.string :isin_no
      t.string :cusip_no
      t.date :reporting_from
      t.date :ceased_at

      t.timestamps
    end
  end
end
