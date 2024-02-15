module OpenFIGIServices
  class GetMultipleTickersService
    attr_reader :funds, :tickers

    def initialize(funds)
      @funds = funds
      @tickers = []
      validate_fund_ids
    end

    def call
      begin
        results = HTTParty.post(
          "https://api.openfigi.com/v3/mapping",
          :headers => { 
            "Content-Type": "application/json",
            "X-OPENFIGI-APIKEY": ENV.fetch("OPENFIGI_API_KEY")
          },
          :body => build_request_body
        )

        if results.response.code == "200"
          results.each_with_index do |result,index|
            fund = @funds[index]

            if !result["error"].nil? || !result["warning"].nil?
              puts "Error/Warning with #{fund.sub_fund_name} " + (!result["error"].nil? ? result["error"] : result["warning"])
              
              # Skip if not retriable
              unless retriable?(fund)
                fund.ticker = "Not Available"
                fund.openfigi_name = "Not Available"
                puts "No OpenFIGI result found for #{fund.sub_fund_name}"
                next
              end

              retried_fund = retry_fund(fund)

              if retried_fund.success?
                fund.ticker = retried_fund.fund.ticker
                fund.openfigi_name = retried_fund.fund.openfigi_name
              else
                fund.ticker = "Not Available"
                fund.openfigi_name = "Not Available"
                puts "No OpenFIGI result found for #{fund.sub_fund_name}"
              end
            else
              fund.ticker = result["data"].first["ticker"]
              fund.openfigi_name = result["data"].first["name"]
              puts "Ticker: #{result["data"].first["ticker"]} - FIGI Name: #{result["data"].first["name"]} - HMRC Name: #{fund.sub_fund_name}"
            end
          end
        end
      rescue => e
        OpenStruct.new({success?: false, error: e})
      else
        OpenStruct.new({success?: true, funds: @funds})
      end
    end

    private

      def validate_fund_ids
        no_id_funds_count = @funds.where("cusip_no = '' AND isin_no = ''").count
        if no_id_funds_count > 0
          raise "#{no_id_funds_count} fund(s) have no CUSIP or ISIN"
        else
          return true
        end
      end

      def retriable?(fund)
        # If CUSIP is present and failed but ISIN is present, retry
        if !fund.cusip_no.empty? && !fund.isin_no.empty?
          return true
        # If CUSIP is not present and ISIN is present and failed, do not retry
        elsif fund.cusip_no.empty? && !fund.isin_no.empty?
          return false
        end
      end

      def retry_fund(fund)
        puts "Retrying..."
        
        if !fund.cusip_no.empty? && !fund.isin_no.empty?
          result = OpenFIGIServices::GetSingleTickerService.new(fund, "isin_no").call
          if result.success?
            puts "Retry successful, found #{result.ticker}"
          else
            puts "Retry failed, #{result.error.message}"
          end

          return result
        end
      end

      def build_request_body
        fund_mappings = []

        @funds.each do |fund|
          mapping = {
            marketSecDes: "Equity"
          }

          if !fund.cusip_no.empty?
            mapping[:idType] = "ID_CUSIP"
            mapping[:idValue] = fund.cusip_no
          elsif !fund.isin_no.empty?
            mapping[:idType] = "ID_ISIN"
            mapping[:idValue] = fund.isin_no
          end

          fund_mappings << mapping
        end

        fund_mappings.to_json
      end
  end
end
