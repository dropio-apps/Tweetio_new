# Author        : William Richerd P
# Designation   : Senior Software Engineer
# Created at    : April 16th 2010
# Last Modified : April 06th 2010
# Features      : 1) Media list method (index Action )
#                 2) Media Details method (show Action)
#                 3) Media delete method (destroy Action)
#                 4) Private methods: drop_asset_delete & media listing

class MediasController < ApplicationController
  # Gems included
  require 'rubygems'
  require 'dropio'
  require 'twitter'
  require "parseconfig"   
  # Media list by User method
  def user_media    
    user_id = get_user_id_by_login(params[:login])
    if user_id == 0
      flash[:rss_notice] = "There is problem access this page"
      redirect_to '/home'
    else
     # @tweets = twitter_follower_list(user_id)
      @user_image,@user_desc = get_twitter_avatar_bio(user_id)
      @user_name = get_user_name_by_id(user_id)      
      @medias = UploadFile.paginate :per_page => 5,:page => params[:page], :order => 'created_at DESC', :conditions=>"user_id=#{user_id}"
      @thumbnail = Array.new
      @medias.each do |media|
        asset_name = media.name
        asset_obj = asset_find(asset_name,media.drop_name)
        if !asset_obj.thumbnail.nil?
          @thumbnail << asset_obj.thumbnail
        else
          if media.content_id == 4
            @thumbnail << "/images/document.png"
          else
            @thumbnail << "/images/media.png"
          end
        end
     end
   end
  end

  def shared    
    @file_detail = UploadFile.find(params[:id])
    media_asset = asset_find(@file_detail.name,@file_detail.drop_name)    
    if params[:content_id].to_i == 1    
      url = media_asset.large_thumbnail    
    elsif params[:content_id].to_i == 4
      url = media_asset.hidden_url
    end    
    redirect_to url
  end

  # Media list method
  def index
    @image_type = params[:type]
    if(@image_type != "all")     
     content_id = UploadFile.get_content_type(@image_type)
     @medias = UploadFile.paginate(:per_page => 5,:page => params[:page],:order =>'created_at DESC',:conditions=>["content_id=?",content_id])
    else
      @medias = UploadFile.paginate(:per_page => 5,:page => params[:page],:order =>'created_at DESC')
    end
    if logged_in?
      user_id = current_user.id
      @user_image,@user_desc = get_twitter_avatar_bio(user_id)
    end
    @thumbnail = Array.new
    @medias.each do |media|
      asset_obj = asset_find(media.name,media.drop_name)
      if !asset_obj.thumbnail.nil?
        @thumbnail << asset_obj.thumbnail
      else
        if media.content_id == 4
          @thumbnail << "/images/document.png"
        else
          @thumbnail << "/images/media.png"
        end
      end
   end
  end

  # Change Asset Name
  def change_asset_name
    encrypt_id = params[:encrypt_id]
    new_media_name = params[:media][:media_name]
    media_id = get_file_id_by_encrypt_id(encrypt_id)
    @file = UploadFile.find(media_id)
    @file.update_attributes(:media_name=>new_media_name)
    redirect_to media_show_path(encrypt_id)
  end

  # Media details method
  def show		
      media_id = get_file_id_by_encrypt_id(params[:id])
      if media_id == 0        
        # Error message display, If file is delete from DB and Drop.io
        @media_error = "Media no longer Exist"
      else
        begin				
          user_id = get_user_id_media_id(media_id)
          @user_image,@user_desc = get_twitter_avatar_bio(user_id)
          @user_name = get_user_name_by_id(user_id)
          # find media with id in DB
          @media_details = UploadFile.find(media_id)
          # Find asset(media) in drop.io.Pass asset name as parameter
          @media_asset = asset_find(@media_details.name,@media_details.drop_name)          
          # Increase the view count
          if flash[:comment_update] != "false"
            @media_details.increment!(:view_count)
          end
		  
          # Create comment object
          @comment = Comment.new(:id => @media_details)
          media_list(@media_details.user_id,media_id)
          @comment_list = @media_details.comments.paginate(:per_page=>5,:page => params[:page], :order => 'created_at DESC')
          @detail_page = true
          @share_url =  HOST+"/medias/show/"+params[:id]
        rescue 
				
          # Error message display, If file is delete from DB and Drop.io
          @media_error = "Media no longer Exist"
        end
      end
  end

  # Media delete Action
  def destroy       
    @media = UploadFile.find(params[:id])
    # Find media(asset) name
    asset_name = @media.name
    # Media list pagination
    if params[:page].nil? or params[:page].empty?
      page_no = 0
    else
      page_no = params[:page]
    end
    page_no = page_no.to_i
    # Delete media in database
    if @media.destroy
      begin
        # Delete media in drop.io
        drop_asset_delete(asset_name)
        if page_no > 1
          page_no = get_page_number(page_no)
          # Redirecting to media list page
          redirect_to medias_user_path(current_user.login,:page=>page_no)
        else
          # Redirecting to media list page
          redirect_to medias_user_path(current_user.login)
        end 
      rescue        
        if page_no > 1
          page_no = get_page_number(page_no)
          # Redirecting to media list page
          redirect_to medias_user_path(current_user.login,:page=>page_no)
        else
          # Redirecting to media list page
          redirect_to medias_user_path(current_user.login)
        end
      end
    end
  end

  # Get User avatar image & description
  def get_twitter_avatar_bio(user_id)
    user = User.find(:first,:conditions=>["id=?",user_id])
    consumer_key,consumer_secret = twitter_consumer_config_value
    oauth = Twitter::OAuth.new(consumer_key,consumer_secret)
    oauth.authorize_from_access(user.access_token, user.access_secret)
    client = Twitter::Base.new(oauth)
    user_data = client.user(user.login)
    return user_data.profile_image_url,user_data.description
  end


  # Private methods
  private

  def get_page_number(page_no)
    record_count = UploadFile.paginate :per_page => 5,:page => page_no,:conditions=>["user_id=#{current_user.id}"]
    if page_no != 1 && record_count.size == 0
      page_no = page_no.to_i - 1
      return page_no
    else
      return page_no
    end    
  end

  # Delete file from drop.io
  def drop_asset_delete(asset_name)
    # Find drop to the current user
    drop_obj = drop_find    
    # Find asset library function
    asset = Dropio::Asset.find(drop_obj, asset_name)   
    # Delete Asset library function
    asset.destroy
  end
  
  # Media List
  def media_list(user_id,media_id)
     @media_list = UploadFile.find(:all,:select=>"*",:order => 'created_at DESC',:limit=>3,:conditions=>["user_id=? AND id NOT IN(#{media_id})",user_id])
     @thumbnail_list = Array.new
     @media_list.each do |media|
        asset_name = media.name
        asset_obj = asset_find(asset_name,media.drop_name)
        if !asset_obj.thumbnail.nil?
          @thumbnail_list << asset_obj.thumbnail
        else
          if media.content_id == 4
            @thumbnail_list << "/images/document.png"
          else
             @thumbnail_list << "/images/media.png"
          end
        end
     end
  end


  # Get Twitter followers list
  def twitter_follower_list(user_id)
    user = User.find(:first,:conditions=>["id=?",user_id])
    # Twitter cosumer key 
    consumer_key,consumer_secret = twitter_consumer_config_value
    oauth = Twitter::OAuth.new(consumer_key,consumer_secret)
    oauth.authorize_from_access(user.access_token, user.access_secret)
    client = Twitter::Base.new(oauth)
    @tweets = client.friends
    return @tweets
  end 
 
end