require 'rubygems'
require 'mail'
require 'tmail'
require 'base64' 
require 'dropio'

# Read the Email to pass the email content as string

def get_file_as_string(filename)
  data = ''
  f = File.open(filename, "r") 
  f.each_line do |line|
    data += line
  end
  return data
end


# Upload file to drop.io API
def uploadFileUsingEmail(email_data)

	mail = TMail::Mail.parse(email_data)
	mail.parts.each do |part|
		if part.disposition == "attachment"
				
			filename = part.disposition_param('filename')
			part_body= part.base64_decode!()   
			puts part_body
			file = File.new(filename,"w+")
			file.write part_body
			file.close
			Dropio::Config.api_key = "cb9cbc7c8c05a10bc613931f9c2d4fd029d9362d"
			Dropio::Config.debug = true        
			auth_drop = Dropio::Drop.find("williamricherd5218")
			auth_drop.add_file(filename)
		end	   

	end
end

#  Parsing Email contents
email_data = get_file_as_string 'william.eml'
uploadFileUsingEmail(email_data)




