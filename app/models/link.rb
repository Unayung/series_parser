class Link < ActiveRecord::Base

  def self.guess_by_url(url)
    link = Link.find_by(:url => url)
    if link.present?
      ### in db
      {:result => "success", :timestamp => link.parse_result}
    else
      ### not in db
      if url.include?("kanmeiju.net")
        parse_kanmeiju(url)
      elsif url.include?("k5.cc")
        parse_k5cc(url)
      else
      end
    end

  end

  def self.parse_kanmeiju(url)
    begin
      list = Nokogiri::HTML(open(url))
      list = list.css('div.vpl')
      timestamp = Time.now.to_i
      File.open("public/results/#{timestamp}.txt", "w") do |file|
        list.css("a").each do |a|
          link = a.attr('href')
          if link.include?("ed2k://") || link.include?("thunder://")
            file.puts link
          end
        end
      end
      check_file_size(url, timestamp)
    rescue Exception => e
      {:result => "fail"}
    end

  end

  def self.parse_k5cc(url)
    begin
      list = Nokogiri::HTML(open(url))
      list = list.css("ul.dllist1")
      timestamp = Time.now.to_i
      File.open("public/results/#{timestamp}.txt", "w") do |file|
        list.css("span.dlbutton1 a").each do |a|
          link = a.attr('href')
          if link.include?("ed2k://") || link.include?("thunder://")
            file.puts link
          end
        end
      end
      check_file_size(url, timestamp)
    rescue Exception => e
      {:result => "fail"}
    end

  end

  def self.check_file_size(url, timestamp)
    f = File.open("public/results/#{timestamp}.txt")
    if f.size > 0
      write_result_to_db(url, timestamp)
      {:result => "success", :timestamp => timestamp}
    else
      {:result => "fail"}
    end
  end

  def self.write_result_to_db(url, timestamp)
    Link.create(:url => url, :parse_result => timestamp)
  end
end
