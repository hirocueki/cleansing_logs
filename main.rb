require './lib/cleanser'
begin
  logs = ARGV
  logs.each do |gz_file|
    puts "proccesing... #{gz_file}"
    tsv_file = "#{gz_file}.tsv"
    if File.exist?(tsv_file)
      puts "skip... #{tsv_file}"
      next
    else
      # log_file = './log/access_log_20190309.gz'
      cleanser = Cleanser.new(gz_file)
      cleanser.wash
      unless cleanser.empty?
        cleanser.save(tsv_file)
      end
    end
  end
rescue SystemCallError => e
  puts "class=[#{e.class}] message=[#{e.message}]"
rescue IOError => e
  puts "class=[#{e.class}] message=[#{e.message}]"
end
