# Author:       William Richerd P
# Designation:  Senior Software Engineer
# Create at:    19th April, 2010
# Last Update:  06th April, 2010
# Features:     1)Add comment(insert Action)
#               2)Twitter share function
#               3)Delete comment
# Plugins used: twitter auth plugin used for twitter share

class CommentsController < ApplicationController
  # Add Comment function
  def insert
    @comment = Comment.new(params[:comment])
    comments = params[:comment][:comments]
    # Twitter will accept only 140 character with URL
    if comments.length > 50
      comments_truncation = comments[0..47]
      comments = comments_truncation + "..."
    end    
    if @comment.save
       # Create URL to share with twitter
       upload_file_id = params[:comment][:upload_file_id]
       # Create message for share in twitter
       tweet_message = create_twitter_message(upload_file_id,comments)
       
       # Call function for share the message in twitter site
       status = tweet(tweet_message)
       flash[:comment_update] = "false"
      if status == 0
	    flash[:notice] = "Comment added successfully"
        redirect_to(request.env["HTTP_REFERER"])
      elsif status == 1
        flash[:notice] = "Sorry.Unable to post the comment in twitter!"
        redirect_to(request.env["HTTP_REFERER"])
      elsif status == 2
        redirect_to "/login"
      end
    else
      flash[:notice] = "Please Enter Comment"
      redirect_to(request.env["HTTP_REFERER"])
    end
  end
  # Delete comment function
  def destroy
    comment_id = params[:id]
    @comment = Comment.find(comment_id)
    if @comment.destroy
      flash[:comment_update] = "false"
      redirect_to(request.env["HTTP_REFERER"])
    end
  end  
end