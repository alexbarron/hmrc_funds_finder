class AddOpenFIGINameToFunds < ActiveRecord::Migration[7.0]
  def change
    add_column :funds, :openfigi_name, :string
  end
end
