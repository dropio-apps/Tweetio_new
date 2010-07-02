# Author:       William Richerd P
# Designation:  Senior Software Engineer
# Create at:    30th April, 2010
# Features:     RSS feed for logged in and not logged in users

class RssController < ApplicationController
  #RSS subscription feed
  require 'rubygems'
	require 'dropio'

  # Rss for not loggedin User
  def rssfeed        
    @medias = UploadFile.find(:all,:order=>'id DESC',:limit=>15)
    if !@medias.nil?
      @thumbnail = Array.new
      @medias.each do |media|
          asset_name = media.name
          asset_obj = asset_find(asset_name,media.drop_name)
          if !asset_obj.thumbnail.nil?
            @thumbnail << asset_obj.thumbnail
          else
            if media.content_id == 4
               @thumbnail  << "/images/document.png"
            else
               @thumbnail  << "/images/media.png"
            end
          end
       end
      render :layout => false
      response.headers["Content-Type"] = "application/xml; charset=utf-8"
    else
      flash[:rss_notice] = "There is problem access RSS.Try again later"
      redirect_to '/home'
    end
  end

  # RSS for logged in User
  def rssfeed_user    
     user_id = get_user_id_by_login(params[:user])
     if user_id != 0
      @medias = UploadFile.find(:all,:conditions=>["user_id='#{user_id}'"])
      @thumbnail = Array.new
      @medias.each do |media|
        asset_name = media.name
        asset_obj = asset_find(asset_name,media.drop_name)
        if !asset_obj.thumbnail.nil?
          @thumbnail << asset_obj.thumbnail
        else
          if media.content_id == 4
             @thumbnail  << "/images/document.png"
          else
              @thumbnail  << "/images/media.png"
          end
        end
      end
      render :layout => false
      response.headers["Content-Type"] = "application/xml; charset=utf-8"
     else
       flash[:rss_notice] = "There is problem access RSS.Try again later"
       redirect_to '/home'
     end     
  end 
end