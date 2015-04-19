class SearchController < ApplicationController
	
	def search
		Action.create(info: current_user.username + ' has made the following search query : (' + params[:q] + ')', user_id: current_user.id)
		@results = User.where(username: params[:q])
		@results += Forum.where(title: params[:q])
		@results += Idea.where(title: params[:q])
	end

end