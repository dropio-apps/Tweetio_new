# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  require "parseconfig"  

  # Get user name by ID
  def get_user_name_by_id(user_id)
    @user = User.find(:first  ,:select=>"name",:conditions=>["id=#{user_id}"])
    return @user.name
  end
  # Get user Id by media ID
  def get_user_id_media_id(media_id)
    @user = UploadFile.find(:first  ,:select=>"user_id",:conditions=>["id=#{media_id}"])
    return @user.user_id
  end
  # Get user details by twitter id
  def get_count_by_twitter_id(twitter_id)
    @user = User.count(:conditions=>["twitter_id=#{twitter_id}"])
    return @user
  end

  # Get user details by twitter id
  def get_user_detail_by_twitter_id(twitter_id)
    @user = User.find(:select=>"*",:conditions=>["twitter_id=#{twitter_id}"])
    return @user
  end

  #get encrypt id by file id
  def get_encrypt_id_by_file_id(file_id)
    @enc_id = UploadFile.find(:first,:select=>"encrypt_id",:conditions=>["id=?",file_id])
    return @enc_id.encrypt_id
  end

  #get file id by encrypt id
  def get_file_id_by_encrypt_id(encrypt_id)    
    @enc_id = UploadFile.find(:first,:select=>"id",:conditions=>["encrypt_id='#{encrypt_id}'"])
    if !@enc_id.nil?
      return @enc_id.id
    else
      return 0
    end
  end

  # Get user id by login
  def get_user_id_by_login(login)
    @user = User.find(:first  ,:select=>"id",:conditions=>["login='#{login}'"])
    if !@user.nil?
      return @user.id
    else
      return 0
    end
  end

  # Get login by twitter id
  def get_login_by_twitter_id(twitter_id)
    @user = User.find(:first  ,:select=>"login",:conditions=>["twitter_id=?",twitter_id])
    return @user.login
  end

  # Get user id by twitter id
  def get_user_id_by_twitter_id(twitter_id)
    @user = User.find(:first  ,:select=>"id",:conditions=>["twitter_id=?",twitter_id])
    return @user.id
  end


  # Get user image by ID
  def get_user_image(user_id)
    @user = User.find(:first,:select=>"profile_image_url",:conditions=>["id=#{user_id}"])
    return @user.profile_image_url
  end
 # Get drop name by user ID
  def get_drop_name_by_user_id(user_id)
    @user = User.find(:first,:select=>"drop_name",:conditions=>["id=?",user_id])
    return @user.drop_name
  end

  # Get user name by Drop ID
  def get_user_id_by_drop_name(drop_name)
    @user = User.find(:first,:select=>"id",:conditions=>["drop_name=?",drop_name])
    return @user.id
  end

  # Authentication check
  def login_required
    if !logged_in?
      redirect_to '/login'
    end
  end

  # Create drop function
  def drop_create
    User.dropio_config
    get_drop_io_admin_password
    drop = Dropio::Drop.create({:name => current_user.login,:admin_password=>get_drop_io_admin_password,:expiration_length=>'1_YEAR_FROM_LAST_VIEW'})#current_user.login
    return drop.name
  end

  # find drop
  def drop_find(drop_name='')    
    if drop_name == ""
      if current_user.drop_name.nil?
        # Create new drop if user does not have
        drop_name = drop_create
        current_user.drop_name = drop_name
        current_user.update_attributes({:drop_name=>drop_name})
      else
        drop_name = current_user.drop_name
      end            
    end    
    # Call dropio configuration
    User.dropio_config
    # Find drop library function
    drop_object = Dropio::Drop.find(drop_name,get_drop_io_token)
    # Return drop object
    return drop_object
  end

  # Find asset function
  def asset_find(asset_name,drop_name="")    
    # Find drop to the current user    
    if drop_name == ""
      drop_obj = drop_find
    else
      drop_obj = drop_find(drop_name)
    end
    # Find asset library function
    asset = Dropio::Asset.find(drop_obj, asset_name)
    # Return asset object    
    return asset
  end

  # Create message for tweeter share
   def create_twitter_message(upload_file_id,description)
    encrypt_id = get_encrypt_id_by_file_id(upload_file_id)
    # Create URL to share with twitter
    twit_url = "#{HOST}/medias/show/#{encrypt_id}"
    if description != ""
      twit_description = description
    else
      twit_description = ""
    end
    # Add description with URL
    if !twit_description.nil?
      tweet_message = twit_description+":"+twit_url
    else
      tweet_message = twit_url
    end
    # Return message
    return tweet_message
   end

  # Message twiting using twitter API
  def tweet(tweet_message)
    if !current_user.nil?
      begin
        @testing = current_user.twitter.post('/statuses/update','status' => tweet_message)        
        return 0
      rescue        
        return 1
      end
    else
      # redirect to log in page is user does not logged in
     return 2
    end
  end   

  # Create Hash for upload file details
  def upload_array(user_id,upload_array_details,content_type,upload_type)
    media_name = upload_array_details.name
     hash_array = {:user_id=> user_id,
          :content_id=>content_type,
          :title=>upload_array_details.title,
          :name=>media_name,
          :description=>upload_array_details.description,
          :created_at =>DateTime.now,
          :original_file_name=>upload_array_details.original_filename,
          :file_size=>upload_array_details.filesize,
          :height=>upload_array_details.height,
          :width=>upload_array_details.width,
          :status=>upload_array_details.status,
          :converted_file_name=>upload_array_details.converted_filename,
          :thumbnail=>upload_array_details.thumbnail,
          :large_thumb=>upload_array_details.large_thumbnail,
          :drop_name=>upload_array_details.drop.name,
          :hidden_url=>upload_array_details.hidden_url,
          :embed_code=>upload_array_details.embed_code,
          :upload_player_type=>upload_type,
          :encrypt_id=>newpass(user_id),
          :name=> media_name
         }
      return hash_array
  end 
  
  # Tweet for email
  def tweet_email_message(user_id,tweet_message)
    user = User.find(:all,:conditions=>["id=?",user_id])
    consumer_key,consumer_secret = twitter_consumer_config_value
    client = TwitterOAuth::Client.new(
    :consumer_key => consumer_key,
    :consumer_secret => consumer_secret,
    :token => user.access_token,
    :secret => user.access_secret)
    client.twitter.post('/statuses/update','status' => tweet_message)
  end

  # save file details in Database
  def upload_save(hash_arr)    
    @upload_file = UploadFile.new(hash_arr)
    if @upload_file.save   
      return @upload_file.id
    end
  end

  # Random generation for URL Encode
  def newpass(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    return Array.new(10){||chars[rand(chars.size)]}.join
  end

  # Date format manupulation
  def format_date(date_value)    
    if date_value.include? "01" or date_value.include? "21" or date_value.include? "31"
      return "st"
    elsif date_value.include? "02" or date_value.include? "22"
      return "nd"
    elsif date_value.include? "03" or date_value.include? "23"
      return "rd"
    else
      return "th"
    end
  end

  # Get twitter consumer key
  def twitter_consumer_config_value
    my_config = ParseConfig.new('config/application.yml')
    consumer_key = my_config.get_value('consumer_key')
    consumer_secret = my_config.get_value('consumer_secret')
    return consumer_key,consumer_secret
  end 

  # Get Drop.io admin password
  def get_drop_io_admin_password
    my_config = ParseConfig.new('config/application.yml')
    admin_password = my_config.get_value('dropio_admin_password')
    return admin_password
  end
  
  # Get Drop.io admin token
  def get_drop_io_token
    my_config = ParseConfig.new('config/application.yml')
    admin_token = my_config.get_value('dropio_api_token')
    return admin_token
  end  
end