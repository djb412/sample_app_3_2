class UsersController < ApplicationController
	before_filter :authenticate, :except => [:show, :new, :create]
	before_filter :correct_user, :only => [:edit, :update]
	before_filter :admin_user, :only => :destroy
	before_filter :redirect_signed_in, :only => [:new, :create]
	before_filter :avoid_destroy_myself, :only => :destroy
 

  def index
	@title = "All users"
	@users = User.paginate(:page => params[:page])
  end

  def show
	@user = User.find(params[:id])
	@microposts = @user.microposts.paginate(:page => params[:page])
	@title = @user.name
  end

  def new
	@user = User.new
	@title = "Sign up"
  end

	def create
		@user = User.new(params[:user])
		if @user.save
			sign_in @user
			flash[:success] = "Welcome to the Sample App!"
		redirect_to @user
		else
			@title = "Sign up"
			
			#@user.password_confirmation = @user.password = nil 
			render 'new'
		end
	end

	def edit
		#@user = User.find(params[:id])
		@title = "Edit user"
	end
	def update
			@user = User.find(params[:id])
		if @user.update_attributes(params[:user])
			flash[:success] = "Profile updated."
			redirect_to @user
		else
			@title = "Edit user"
			render 'edit'
		end
	end

	def destroy
		user = User.find(params[:id])
		if current_user?(user)
		 flash[:error] = "Admin suicide warning: Can't delete yourself."
		 else

		user.destroy
		flash[:success] = "User destroyed."
		end
 		redirect_to users_path
	end
	
	def following
		show_follow(:following)
	end
	def followers
		show_follow(:followers)
	end
	def show_follow(action)
		@title = action.to_s.capitalize
		@user = User.find(params[:id])
		@users = @user.send(action).paginate(:page => params[:page])
		render 'show_follow'
	end

	private
		def authenticate
			deny_access unless signed_in?
		end
		def correct_user
			@user = User.find(params[:id])
			redirect_to(root_path) unless current_user?(@user)
		end
		def admin_user
			redirect_to(root_path) if !current_user.admin? || current_user?(@user)
		end
 		def redirect_signed_in  
			flash[:success] = "You are already a user!"  
			redirect_to(root_path) if signed_in?  
		end
		def avoid_destroy_myself
		 	@user = User.find(params[:id])
		 	redirect_to users_path, 
			:notice => "You can not destroy yourself" unless !current_user?(@user)
		 end


end
