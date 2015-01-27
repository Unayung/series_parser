class Link

  def self.guess_by_url(url)
    if url.include?("kanmeiju.net")
      parse_kanmeiju(url)
    elsif url.include?("k5.cc")
      parse_k5cc(url)
    else

    end

  end

  def self.parse_kanmeiju(url)
    begin
      list = Nokogiri::HTML(open(url))
      list = list.css('div.vpl')
      timestamp = Time.now.to_i
      File.open("public/#{timestamp}.txt", "w") do |file|
        list.css("a").each do |a|
          link = a.attr('href')
          if link.include?("ed2k://") || link.include?("thunder://")
            file.puts link
          end
        end
      end
      check_file_size(timestamp)
    rescue Exception => e
      {:result => "fail"}
    end

  end

  def self.parse_k5cc(url)
    begin
      list = Nokogiri::HTML(open(url))
      list = list.css("ul.dllist1")
      timestamp = Time.now.to_i
      File.open("public/#{timestamp}.txt", "w") do |file|
        list.css("span.dlbutton1 a").each do |a|
          link = a.attr('href')
          if link.include?("ed2k://") || link.include?("thunder://")
            file.puts link
          end
        end
      end
      check_file_size(timestamp)
    rescue Exception => e
      {:result => "fail"}
    end

  end

  def self.check_file_size(timestamp)
    f = File.open("public/#{timestamp}.txt")
    if f.size > 0
      {:result => "success", :timestamp => timestamp}
    else
      {:result => "fail"}
    end
  end
end
