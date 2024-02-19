namespace :import do
  desc "imports funds data from CSV using batch method"
  task :batch_record, [:filepath] => :environment do |task, args|
    funds = []

    CSV.foreach(args.filepath, headers: true) do |row|
      funds << row
    end

    new_funds = funds.map do |attrs|
      if !(attrs["cusip_no"] =~ /[0-9]{3}-[0-9]{2}[a-zA-Z]{1}-[0-9]{3}/).nil?
        attrs["cusip_no"] = attrs["cusip_no"].gsub("-","")
      end

      Fund.new(attrs)
    end

    time = Benchmark.realtime {Fund.import(new_funds)}
    puts time
  end
end