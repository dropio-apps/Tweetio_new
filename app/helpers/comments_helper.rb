module CommentsHelper
  def total_comment_count(media_id)
    media_count = Comment.count(:conditions=>["upload_file_id=#{media_id}"])
    return  media_count
  end
end
