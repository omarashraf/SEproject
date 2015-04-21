class SysadminsController < ApplicationController
  def new
  end

  def index
  end

  def show              #show system admin view
    if current_user
      redirect_to logged_in_path and return
    end

    if session[:sysadmin] == "true" or (params[:sysadmin][:username] == 'admin' and params[:sysadmin][:password] == 'password')
      session[:sysadmin] = "true"
      render 'show'
    else
      flash[:notice] = "Wrong email/password combination."
      redirect_to(:action => 'new') 
    end
  end

  def edit
    @user_tmp = User.find_by(email: params[:email_delete])
    @users = User.all
    if !@user_tmp
      redirect_to missingUser_path
    else
      if @user_tmp.destroy
        redirect_to deleteUser_path
      else
        render 'show'
      end
    end
  end

  def deleteUser
  end

  def missingUser
  end

  def userBlocked
    @user_to_be_blocked = User.find_by(email: params[:block_user])
    if !@user_to_be_blocked
      render 'show'
    else
      @block = Block.new(email: @user_to_be_blocked.email)
      if @block.save
        redirect_to blocked_path
        Action.create(info: 'A system admin has blocked: (' + @user_to_be_blocked.username + ').', user_id: -1)
      else
        render 'show'
      end
    end
  end

  def userUnblocked
    @user_to_be_unblocked = User.find_by(email: params[:unblock_user])
    if !@user_to_be_unblocked
      render 'show'
    else
      @unblock = Block.find_by(email: @user_to_be_unblocked.email)
      if @unblock.destroy
        redirect_to unblocked_path
        Action.create(info: 'A system admin has unblocked: (' + @user_to_be_unblocked.username + ').', user_id: -1)
      else
        render 'show'
      end
    end
  end

  def forums
    @forums = Forum.all
  end

  def delete
  end 

  # This action is only for rendering the merge view
  def merge
  end

  # This is where merging occurs. The older of the two forums is kept in the database with the new name and description
  # specified, and all the ideas and members of the other forum are transferred to that one. Only the admins of the older
  # froum remain. Finally, the other forum is deleted from the database and the older one is considered to be the
  # merged version.
  def createMerge
    if params[:forum][:forum1_id] == params[:forum][:forum2_id]
      flash[:notice] = "Can only merge different forums!"
      render 'merge'
    else
      forum1_id = params[:forum][:forum1_id]
      forum2_id = params[:forum][:forum2_id]

      forum1 = Forum.where({ id: forum1_id })
      forum2 = Forum.where({ id: forum2_id })

      old_forum_id = 0
      new_forum_id = 0

      if forum1.first.privacy == forum2.first.privacy
        if forum1.first.created_at < forum2.first.created_at
          old_forum_id = forum1_id
          new_forum_id = forum2_id
        else
          old_forum_id = forum2_id
          new_forum_id = forum1_id
        end

        name = params[:forum][:name]
        description = params[:forum][:description]
            
        ideas = Idea.where({ forum_id: new_forum_id })
        memberships = Membership.where({ forum_id: new_forum_id })

        ideas.each do |i|
          i.forum_id = old_forum_id
          i.save
        end

        memberships.each do |m|
          m.forum_id = old_forum_id
          m.save
        end

        old_forum = Forum.where({ id: old_forum_id })
        old_forum.first.title = name
        old_forum.first.description = description
        old_forum.first.save

        new_forum = Forum.where({ id: new_forum_id })

        Action.create(info: 'A system admin has merged forum: (' + old_forum.first.title + ') and forum: (' + new_forum.first.title + ') into one.', user_id: -1)

        new_forum.first.destroy

        # For now
        redirect_to('/sysadmins/index')
      else
        flash[:notice] = "Can only merge forums of the same privacy setting!"
        render 'merge'
      end
    end
  end
end
