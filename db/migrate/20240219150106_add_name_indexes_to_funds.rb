class AddNameIndexesToFunds < ActiveRecord::Migration[7.0]
  def change
    add_index :funds, :parent_fund
    add_index :funds, :sub_fund_name
    add_index :funds, :openfigi_name
  end
end
