# Author        : Begin Samuel
# Designation   : Technical Lead

class EmailController < ApplicationController

protect_from_forgery :only => [:update, :delete, :create]

  # Dropio Gem included
  require 'dropio'
  require 'tmail'
  require 'base64'
  require "parseconfig"
  #require 'twitter'
  
  # Include Helper class
  def message
	mail = TMail::Mail.parse(params[:email])	
  description = mail.subject  
	mailstr = mail.to
	mailstr = mailstr.to_s
	mailstr = mailstr.chop
	to_mail_id = (mailstr).split("@")
  drop_name = to_mail_id[0]
  drop_count = User.count(:conditions=>["drop_name=?",drop_name])
  
  if drop_count > 0
    user_id = get_user_id_by_drop_name(drop_name)
    upload_type = 1    
    mail.parts.each do |part|            
      if part.disposition == "attachment"        
        filename = part.disposition_param('filename')
        part_body= part.base64_decode!()        
        filename ="/tmp/"+filename.to_s
        file_type ="/tmp/"+filename.to_s
        filename = filename.chop
        file = File.new(filename,"wb+")
        file.write part_body
        file.close        
        if file.closed?
          if File.exists?(filename)
            User.dropio_config
            auth_drop = Dropio::Drop.find(drop_name)
            upload_file_details = auth_drop.add_file(filename,description)			
            content_type = UploadFile.get_content_type_from_url(file_type)
			      # Create Hash for upload
            hash_array = upload_array(user_id,upload_file_details,content_type,upload_type)
            # Save values in databse
            upload_file_id = upload_save(hash_array)
            comments =  mail.subject.to_s
            if comments.length > 50
              comments = comments[0..47]
              comments = comments+"..."
            end
            # Create twitter message
            tweet_message = create_twitter_message(upload_file_id,comments)
            # Call the function for share the message in twitter site
            tweet_email_message(user_id,tweet_message)
          end
        end
      else
          puts part.body
      end
    end
  end
    render:text=> "sent"
  end
   

   def tweet_email_message(user_id,tweet_message)
    user = User.find(:first,:conditions=>["id=?",user_id])
    # Twitter cosumer key
    consumer_key,consumer_secret = twitter_consumer_config_value
    oauth = Twitter::OAuth.new(consumer_key, consumer_secret)
    oauth.authorize_from_access(user.access_token, user.access_secret)
    client = Twitter::Base.new(oauth)
    client.update(tweet_message)
   end

   def email     
   end
   
   def send_email      
      
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

     begin
     sendEmail params['uploadfile']['to_email'], params['uploadfile']['subject'], upload_file_name
     flash[:email_notice] = "Email has been sent."
     rescue
       flash[:email_notice] = "Email has not been sent. Please try again later"
     end
     redirect_to "/email/email"
   end

   def sendEmail(to_add,subject,file)

	tomail = to_add
	frommail = 'wemmaster@tweet.io'
	attachments =[file]

	mail = TMail::Mail.new
	mail.to = tomail
	mail.from = frommail
	mail.subject = subject
	mail.date = Time.now


	mailpart=TMail::Mail.new
	mailpart.set_content_type 'text', 'plain'
	mailpart.body = subject
	mail.parts << mailpart


	attachments.each do |att|
		if FileTest.exists?("public/images/dropio/"+att.to_s)
		ifile = File.open("public/images/dropio/"+att.to_s,"rb")
		content=ifile.read
		ifile.close
		mailpart=TMail::Mail.new
		mailpart.set_content_type 'image', 'jpeg'
		mailpart.set_disposition("attachment", {:filename => "#{att}"})
		mailpart.transfer_encoding = "base64"
		content = Base64.b64encode(content.to_s)
		mailpart.body = content.to_s
		mail.parts << mailpart
		end
	end

	Net::SMTP.start('localhost', 25) do|smtpclient|
	  smtpclient.send_message(mail.to_s,frommail,tomail)
  end

  end

  
end 