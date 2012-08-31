class CommentsController < ApplicationController
  force_ssl_with_params_fix

  def create
    redirect_to root_url, :flash => {:error => t('user.access_denied')} unless user_logged_in? and current_user.can_comment?
    comment = Comment.new(params[:comment].merge :commentable_type => 'Project', :user_id => current_user_id)
    if comment.save
      flash[:notice] = t('common.ok')
    else
      flash[:error] = comment.errors.full_messages.join(' ')
    end
    redirect_to :back
  end
end
