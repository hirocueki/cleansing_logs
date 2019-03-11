require 'pry'
require 'cgi'
require 'zlib'

class Cleanser
  attr_accessor :gz_file, :datas

  def initialize(gz_file)
    @gz_file = gz_file
    @datas = []
  end

  def empty?
    @datas.empty?
  end

  def format(date:, file:)
    category = file.dup
    category.gsub!(%r{(\/mynews|\/cache|\/text)}, '')
    category.gsub!(%r{(\/[0-9]+.html|\/\w+.xml|.php\?.+)}, '')
    "#{date}\t#{category}\t#{file}"
  end

  def validate?(method:, file:)
    return false unless method == 'GET'
    return false unless file.start_with?('/mynews')
    return false if file.include?('/tplmsg/license')
    return false if file.include?('/test')
    return false if file.end_with?('limitation.bmp')
    return false if file.include?('manual/release')
    true
  end

  def linkrss_host(file)
    return file unless file.start_with?('/mynews/linkrss')
    link = file.match(/url=([^&]+)/)[1]
    link = CGI.unescape(link)
    "/mynews/linkrss/#{URI.parse(link).host}"
  end

  def cleanse(line)
    line = line.encode(
      'UTF-16BE',
      'UTF-8',
      invalid: :replace,
      undef: :replace,
      replace: '?'
    ).encode('UTF-8')
    date = line.scan(/\[(.*?)\]/).flatten.first
    url =  line.scan(/"(.*?)"/).flatten.first
    parts = url.split(' ')
    return if parts.count < 3
    return nil unless validate?(method: parts[0], file: parts[1])
    { date: date, file: linkrss_host(parts[1]) }
  end

  def wash
    Zlib::GzipReader.open(@gz_file) do |gz|
      gz.each do |line|
        hash = cleanse(line)
        unless hash.nil?
          @datas.push(hash)
        end
      end
    end
  end

  def save(tsv_file)
    File.open(tsv_file, 'w') do |file|
      file.puts "アクセス日\tカテゴリ\tURL"
      @datas.each do |hash|
        file.puts format(hash)
      end
    end
  end
end
