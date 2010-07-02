class Comment < ActiveRecord::Base
  belongs_to :users
  belongs_to :upload_files
  validates_presence_of :comments
end