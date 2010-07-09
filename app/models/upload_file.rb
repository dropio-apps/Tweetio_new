class UploadFile < ActiveRecord::Base
  belongs_to :user
  has_many :comments,:order=>'created_at DESC',:dependent=>:destroy
  belongs_to :content    
  #To get Sql query based on content type.
  named_scope :type_of_content, 
    lambda { |type| 
      {:joins => :content,:conditions => {:contents=>{:content_type => type}},:order => 'id DESC' } }
    
 def type_content?
   type = self.content
   return type.content_type
 end

  # Get the uploading file content type
  def self.get_content_type(type)    
    content = Content.find_by_content_type(type)    
    if content.nil?
      return 4
    else
      return content.id
    end
  end

  # Get content type form url
  def self.get_content_type_from_url(url)
    url = url.downcase
    if url.include? '.png' or url.include? '.jpg' or url.include? '.gif' or url.include? '.bmp'
      return 1
    elsif url.include? '.wmv' or url.include? '.mov' or url.include? '.3gp' or url.include? '.mp4' or url.include? '.mpg' or url.include? '.rm'
      return 2
    elsif url.include? '.mp3' or url.include? '.wav' or url.include? '.ra' or url.include? '.wma'
      return 3
    elsif url.include? '.txt' or url.include? '.doc' or url.include? '.pdf' or url.include? '.xls'
      return 4
    else      
      return 4
    end
  end
end