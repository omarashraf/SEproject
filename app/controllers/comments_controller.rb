class CommentsController < ApplicationController
	before_action :authenticate_user, only: [:create, :reportcomment, :destroy]

	#index method list all the comments related to an idea.
	def index
		@comments = Comment.where(idea_id: params[:idea_id])
	end

	# creates a new comment
   def new
   	@idea = Idea.find(params[:idea_id])
		@comment = Comment.new
   end

   #enables the user to post a comment on an idea.
	def create
		@forum = Forum.find(params[:forum_id])
		@comment = @idea.comments.build(comment_params)
		@comment.user = current_user

		if @comment.save
			
			# This line of code sends a notification to the owner of the idea being commented on
			if current_user.id != @idea.user_id
				Notification.create(info: current_user.username + ' has commented: (' + @comment.text + ') on your idea: (' + @idea.title + ') on forum: (' + Forum.find(@idea.forum_id).title + ').', seen: false, user_id: @idea.user_id, link: '/forums/' + @idea.forum_id.to_s + 'ideas/' + @idea.id.to_s)
			end
			
			Action.create(info: current_user.username + ' has commented: (' + @comment.text + ') on idea: (' + @idea.title + ') belonging to user: (' + User.find(@idea.user_id).username + ') on forum: (' + Forum.find(@idea.forum_id).title + ').', user_email: current_user.email)
			
			redirect_to [@forum, @idea] 
		else
			render template: 'ideas/show'
		end
	end
# used to allow user to report a certain comment
	def reportcomment
		@forum = Forum.find(params[:forum_id])
		@user = current_user
		@idea = Idea.find(params[:idea_id])
		@comment = Comment.find(params[:id])

	 	@reportcomment = Reportcomment.new(:user_id => @user.id , :comment_id => @comment.id)

		if @reportcomment.save
	   		flash[:notice] = "Comment has been reported!"
	   		Action.create(info: User.find(@user.id).username + ' has reported a comment: (' + @comment.text + ') belonging to user: (' + User.find(@comment.user_id).username + ') present in idea: (' + Idea.find(@comment.idea_id).title + ') in forum: (' + Forum.find(Idea.find(@comment.idea_id).forum_id).title + ').', user_email: @user.email)
	   		Notification.create(info: 'Your comment: (' + @comment.text + ') on idea: (' + @idea.title + ') on forum: (' + @forum.title + ') has been reported', seen: false, user_id: @comment.user_id, link: '/forums/' + @idea.forum_id.to_s + 'ideas/' + @idea.id.to_s)
		end

      	redirect_to forum_idea_path(@forum, @idea) # [@forum, @idea]
	end

	def unreportcomment 
		@user = current_user
		@forum = Forum.find(params[:forum_id])
		@idea = Idea.find(params[:idea_id])
		@comment = Comment.find(params[:id])
		if !Reportcomment.where(user_id: @user.id, idea_id: @idea, comment_id: @comment).empty?
			@reportcomment = Reportcomment.where(user_id: @user.id, idea_id: @idea, comment_id: @comment)
			@reportcomment.destroy
			flash[:notice] = "Comment has been unreported!"
		end	
		redirect_to forum_idea_path(@forum, @idea)
	end 
# used to allow user to delete his comments
	def destroy
		@forum = Forum.find(params[:forum_id])
		@user = current_user
		@idea = Idea.find(params[:idea_id])
		@comment = Comment.find(params[:id])


		#if 	session[:sysadmin] or @comment[:user_id] == @user[:id]
			@comment.destroy
			flash[:notice] = "comment deleted"
			if current_user == nil
				Action.create(info: 'A system administrator has deleted a comment: (' + @comment.text + ') on idea: (' + @idea.title + ') on forum: (' + @forum.title + ').', user_email: 'SystemAdmin')
				Notification.create(info: 'Your comment: (' + @comment.text + ') on idea: (' + @idea.title + ') on forum: (' + @forum.title + ') has been deleted.', user_id: @comment.user_id, link: '/forums/' + @idea.forum_id.to_s + 'ideas/' + @idea.id.to_s)
			elsif @comment.user_id == @user.id
				Action.create(info: @user.username + ' has deleted his comment: (' + @comment.text + ') on idea: (' + @idea.title + ') on forum: (' + @forum.title + ').', user_email: @user.email)
			else
				Action.create(info: @user.username + ' has deleted a comment: (' + @comment.text + ') on idea: (' + @idea.title + ') on forum: (' + @forum.title + ') belonging to ' + User.find(@comment.user_id).username + '.', user_email: @user.email)
				Notification.create(info: 'Your comment: (' + @comment.text + ') on idea: (' + @idea.title + ') on forum: (' + @forum.title + ') has been deleted.', user_id: @comment.user_id, link: '/forums/' + @idea.forum_id.to_s + 'ideas/' + @idea.id.to_s)
			end
		#else
		#	flash[:notice] = "You can only delete your comments!"
		#end

      	redirect_to forum_idea_path(@forum, @idea)
	end

# used to allow the user to enter the comment and nothing more inorder not to be able to change the comment's model
	protected
	def comment_params
		params.require(:comment).permit(:text)
	end

# check for user secession (makes sure a user is logged in)
	def authenticate_user
		@idea = Idea.find(params[:idea_id])

		if current_user == nil and !session[:sysadmin]
			redirect_to login_path
		end

	end
end
