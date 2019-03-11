require 'pry'
require 'cgi'

def format(date:, file:)
  category = file
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

def cleanse(log)
  date = log.scan(/\[(.*?)\]/).flatten.first
  url =  log.scan(/"(.*?)"/).flatten.first

  parts = url.split(' ')

  return if parts.count < 3
  return {} unless validate?(method: parts[0], file: parts[1])
  { date: date, file: linkrss_host(parts[1]) }
end

begin
  log_file = '../log/access_log_20190309'
  hashies = []
  File.foreach(log_file) do |log|
    hashies.push(cleanse(log))
  end
  File.open("#{log_file}_o.tsv", 'w') do |file|
    file.puts "アクセス日\tカテゴリ\tURL"

    hashies.each do |log|
      if log.nil?
        next
      elsif !log.empty?
        file.puts format(log)
      end
    end
  end
rescue SystemCallError => e
  puts "class=[#{e.class}] message=[#{e.message}]"
rescue IOError => e
  puts "class=[#{e.class}] message=[#{e.message}]"
end
