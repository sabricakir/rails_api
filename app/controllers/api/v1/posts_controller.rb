class Api::V1::PostsController < Api::V1::AuthenticateController
  include Pagy::Backend

  before_action :set_post, only: %i[show edit update destroy]

  # GET /posts or /posts.json
  def index
    user_posts = current_user.posts
    @pagy, @posts = pagy(user_posts, items: 2)
    @pagy_metadata = pagy_metadata(@pagy)
  end

  # GET /posts/1 or /posts/1.json
  def show; end

  # GET /posts/new
  def new
    @post = current_user.posts.new
  end

  # GET /posts/1/edit
  def edit; end

  # POST /posts or /posts.json
  def create
    @post = current_user.posts.new(post_params)

    respond_to do |format|
      if @post.save
        format.json { render json: @post, status: :created, location: api_v1_post_url(@post) }
      else
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.json { render json: @post, status: :ok, location: api_v1_post_url(@post) }
      else
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy

    respond_to do |format|
      format.json { render json: { message: 'Post was successfully destroyed.' }, status: :ok }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = current_user.posts.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def post_params
    params.require(:post).permit(:title, :body)
  end
end
