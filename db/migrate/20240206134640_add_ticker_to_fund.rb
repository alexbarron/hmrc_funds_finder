class AddTickerToFund < ActiveRecord::Migration[7.0]
  def change
    add_column :funds, :ticker, :string
    add_index :funds, :ticker
  end
end
