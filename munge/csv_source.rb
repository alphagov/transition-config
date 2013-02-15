require 'csv'

NilAsBlankConverter = ->(heading) { heading || "" }

class CsvSource

  def input_csv
    @input_csv ||= normalize_column_names(CSV.parse(read_data, headers: true, header_converters: [NilAsBlankConverter, :downcase]))
  end

  def normalize_column_names(rows)
    Enumerator.new do |yielder|
      rows.each_with_index do |row, i|
        yielder << {
          'source' => source,
          'row_number' => i + 2,
          'old url' => row['old url'],
          'new url' => row['new url'],
          'status'  => row['status']
        }
      end
    end
  end
end

class RemoteCsvSource < CsvSource

  def initialize(csv_url)
    @csv_url = csv_url
  end

  def source
    @csv_url
  end

  def read_data
    do_request(@csv_url).body.force_encoding("UTF-8")
  end

  def do_request(url)
    $stderr.puts "Reading CSV from #{url}..."
    uri = URI.parse(url)
    raise "url must be HTTP(S)" unless uri.is_a?(URI::HTTP)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.is_a?(URI::HTTPS))
    response = http.request_get(uri.path + "?" + uri.query)
    raise "Error - got response #{response.code} on #{url}" unless response.is_a?(Net::HTTPOK)
    response
  end
end

class LocalCsvSource < CsvSource
  def initialize(path)
    @path = path
  end

  def source
    @path
  end

  def read_data
    $stderr.puts "Reading CSV from #{@path}..."
    File.open(@path, 'r:utf-8') {|f| f.read}
  end
end

class StringCsvSource < CsvSource
  def initialize(data)
    @data = data
  end

  def source
    'passed in string'
  end

  def read_data
    @data
  end
end

