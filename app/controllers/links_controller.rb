class LinksController < ApplicationController

  def parse_link
    if params["link_url"].size > 0
      result = Link.guess_by_url(params["link_url"])
      if result[:result] == "success"
        redirect_to link_path(result[:timestamp])
      else
        flash[:alert] = "賣鬧啦"
        redirect_to :root
      end
    else
      flash[:alert] = "賣鬧啦"
      redirect_to :root
    end

  end

  def show
    if params[:id].present? && File.exist?("public/results/#{params[:id]}.txt")
      @f = File.open("public/results/#{params[:id]}.txt")
      @link = Link.find_by(:parse_result => params[:id])
    else
      redirect_to :root, :notice => "沒這東西喔大大"
    end
  end
end
