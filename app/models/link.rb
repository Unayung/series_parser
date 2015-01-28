class Link < ActiveRecord::Base

  def self.guess_by_url(url)
    link = Link.find_by(:url => url)
    if link.present?
      ### in db
      if (Time.now.to_i - link.updated_at.to_i) > 7200
        ### renew file every 2 hours
        select_parsing_method(url)
      else
        {:result => "success", :timestamp => link.parse_result}
      end

    else
      ### not in db
      select_parsing_method(url)
    end

  end

  def self.select_parsing_method(url)
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

      title = list.css("div.vshow h2").text
      update_status = list.css("div.vshow p").first.text

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
      check_file_size(url, timestamp, title, update_status)
    rescue Exception => e
      {:result => "fail", :msg => e}
    end

  end

  def self.parse_k5cc(url)
    begin
      list = Nokogiri::HTML(open(url))

      title = list.css("title").text.gsub(" - 80s手机电影","").gsub("\n","")
      update_status = list.css("div.info span.tip").text.gsub("\n    ","").gsub(" ","")

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
      check_file_size(url, timestamp, title, update_status)
    rescue Exception => e
      {:result => "fail", :msg => e}
    end

  end

  def self.check_file_size(url, timestamp, title, update_status)
    f = File.open("public/results/#{timestamp}.txt")
    if f.size > 0
      write_result_to_db(url, timestamp, title, update_status)
      {:result => "success", :timestamp => timestamp, :title => title, :update => update_status}
    else
      {:result => "fail"}
    end
  end

  def self.write_result_to_db(url, timestamp, title, update_status)
    link = Link.find_by(:url => url)
    if link.present?
      remove_old_result_file(link.parse_result)
      link.update(:parse_result => timestamp, :title => title, :update_status => update_status)
    else
      Link.create(:url => url, :parse_result => timestamp, :title => title, :update_status => update_status)
    end
  end

  def self.remove_old_result_file(timestamp)
    if File.exist?("public/results/#{timestamp}.txt")
      File.delete("public/results/#{timestamp}.txt")
    end
  end
end
