# Author:       William Richerd P
# Designation:  Senior Software Engineer
# Create at:    15th April, 2010
# Last Update:  06th May, 2010
# Features:     1)Home page(index Action)
#               2)File upload in drop.io site using API(file_upload and upload_dropio actions)
#               3)Twitter share 
#               4)Twitter oAuth callback function
#               5)uopload data save in upload_files table
# Gems used:    Dropio gem used for drop.io API upload
# Plugins used: twitter auth plugin used for oAuth authentication

class HomeController < ApplicationController
	require 'rubygems'
	require 'dropio'
  require 'twitter'
	before_filter :login_required, :except => [:index,:redirect_media]


  #Home page
  def index      
    @thumbnail = Array.new
    @user_image = ""
    @user_desc = ""    
  end

  # File upload form
  def file_upload    
    @user_image = ""
    @user_desc = ""
    login = current_user.login
    user_id = get_user_id_by_login(login)
    @medias = UploadFile.paginate :per_page => 3,:page => params[:page], :order => 'created_at DESC', :conditions=>"user_id=#{user_id}"
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

  # File upload submit action
  def upload_dropio
    # Error validation function
    validation_status = error_validation
    # if validation function return false, redirect to previous page with valid error message
    if !validation_status
      redirect_to media_file_upload_path
    else
      if !params['uploadfile']['file_field'].nil?
        upload_file_name =  params['uploadfile']['file_field'].original_filename
        # Get upload file type
        get_media_type = params['uploadfile']['file_field'].content_type
        # Split the upload file type and get the file type in array[0]        
        media_type = get_media_type.split("/")
        # Get content file type id
        content_type = UploadFile.get_content_type(media_type[0])
        # Upload directory path
        upload_directory = "public/images/dropio"
        # create the file path
        path = File.join(upload_directory, upload_file_name)
        # write the file
        File.open(path, "wb") { |f| f.write( params['uploadfile']['file_field'].read) }
        # Assign file path to variable
        upload_file_path = path
        # find file upload type(via directory)
        upload_type = 1
      else
        # Upload file using URL
        if !params['uploadfile']['file_url'].nil?
          if !params['uploadfile']['file_url'].empty?           
            # Assign file path to variable
            upload_file_path = params['uploadfile']['file_url']
            # find file upload type(via URL)
            upload_type = 2           
            # Get upload media's type
            content_type = UploadFile.get_content_type_from_url(upload_file_path)
          end
        end
      end

      # Exception handling for file upload
      begin
        # Get description
        description = params['uploadfile']['description']
        # Upload file to drop.io
        begin
          upload_file_details = drop_file_upload(upload_file_path,upload_type,description)
        rescue          
          flash[:file_upload_error] = "Error while uploading file. Try later"
          redirect_to media_file_upload_path
        end
          # Create hash for save upload datas in database
          user_id = params['uploadfile']['user_id']
          hash_array = upload_array(user_id,upload_file_details,content_type,upload_type)
          begin
            # Save values in databse
            upload_file_id = upload_save(hash_array)
          rescue
            flash[:file_upload_error] = "Error while saving in databae"
          end
          begin
            if description.length > 50
              description = upload_file_details.description[0..47]
              description = description+"..."            
            end
            # Get message for twitter share
            tweet_message = create_twitter_message(upload_file_id,description)
            # Call the function for share the message in twitter site
            tweet(tweet_message)
          rescue
            flash[:file_upload_error] = "Error While tweeting message using twitter API.Try again later"
            redirect_to media_file_upload_path
          end
        # Redirect with successful message          
          flash[:file_upload_error] = "Media Uploaded Successfully"
          redirect_to media_file_upload_path
      rescue
        # Notice Error message
        flash[:file_upload_error] = "Error while uploading file. Try later"
        # Redirect to Home page
        redirect_to media_file_upload_path
      end
    end
  end

  def redirect_media
    media_path = UploadFile.find_by_name(params[:asset_name])
    redirect_to media_path.hidden_url
  end
  
  # Private methods
  private
  # Drop file upload using Drop.io APIs
  def drop_file_upload(upload_path,upload_type,description)
    drop_obj = drop_find
    # File upload through file field
    if upload_type == 1
      file_details = drop_obj.add_file(upload_path,description)
    elsif upload_type == 2
      # File upload through url
      file_details = drop_obj.add_file_from_url(upload_path,description)
    end
    return file_details
  end

  # Droped contents saves in twit.io's Database
  def upload_save(hash_arr)    
    @upload_file = UploadFile.new(hash_arr)
    if @upload_file.save   
      return @upload_file.id
    end
  end
  
  # Error validation function
  def error_validation    
    if params[:uploadfile][:file_field].nil? && params[:uploadfile][:file_url].empty?
        flash[:file_upload_error] = "Select file or Enter the URL for upload"
        return false
    else
      # validation for URL upload
      if !params[:uploadfile][:file_url].empty?
        content_type = UploadFile.get_content_type_from_url(params[:uploadfile][:file_url])
        if content_type == 5
          flash[:file_upload_error] = "Invalid file format"
          return false
        end
      end
      return true
    end
  end
  
  def image_aspect(height,width)
    height = height.to_i
    width = width.to_i
    static_width = 50
    if width > height or width == height
      fraction = width/height
      height = static_width * width/height * fraction      
    else
      fraction = height/width
      height = static_width * height/width * fraction 
    end
    return static_width.to_i,height.to_i
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
end