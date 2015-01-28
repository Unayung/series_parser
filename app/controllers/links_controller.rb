class LinksController < ApplicationController

  def parse
    if !params["link_url"].nil?
      result = Link.guess_by_url(params["link_url"])
      if result[:result] == "success"
        redirect_to link_path(result[:timestamp])
      else
        redirect_to root_path, :alert => "賣鬧"
      end
    end

  end

  def show
    if params[:id].present? && File.exist?("public/results/#{params[:id]}.txt")
      @f = File.open("public/results/#{params[:id]}.txt")
      @link = Link.find_by(:parse_result => params[:id])
    else
      redirect_to root_path, :notice => "沒這東西喔大大"
    end
  end
end
