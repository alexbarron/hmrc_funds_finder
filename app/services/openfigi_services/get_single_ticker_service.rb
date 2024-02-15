module OpenFIGIServices
  class GetSingleTickerService
    attr_reader :fund, :preferred_id

    def initialize(fund, preferred_id = "cusip_no")
      @fund = fund
      @preferred_id = preferred_id
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
          if results.first["error"]
            puts "ERROR with #{@fund.sub_fund_name} " + results.first["error"]
            raise "Lookup failed with error: #{results.first["error"]}"
          elsif results.first["warning"]
            puts "WARNING with #{@fund.sub_fund_name} " + results.first["warning"]
            raise "Lookup failed with warning: #{results.first["warning"]}"
          else
            @fund.ticker = results.first["data"].first["ticker"]
            @fund.openfigi_name = results.first["data"].first["name"]
            puts "Ticker: #{@fund.ticker} - FIGI Name: #{@fund.openfigi_name} - HMRC Name: #{@fund.sub_fund_name}"
          end
        end
      rescue => e
        OpenStruct.new({success?: false, error: e})
      else
        OpenStruct.new({success?: true, fund: @fund})
      end
    end

    private

      def build_request_body
        mapping = {
          marketSecDes: "Equity"
        }

        if @preferred_id == "isin_no" && !@fund.isin_no.empty?
          mapping[:idType] = "ID_ISIN"
          mapping[:idValue] = @fund.isin_no
        elsif !fund.cusip_no.empty?
          mapping[:idType] = "ID_CUSIP"
          mapping[:idValue] = @fund.cusip_no
        else
          raise "Fund has no CUSIP or ISIN"
        end

        [mapping].to_json # OpenFIGI Mapping API requires array
      end
  end
end