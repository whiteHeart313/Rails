class PostDeletionWorker
  include Sidekiq::Worker
  
  # This method will be called by Sidekiq to perform the deletion (running somehow in the background)
  # This runs in a Sidekiq worker process, not in the web application process (WOW this is cool)
  def perform(post_id)
    post = Post.find_by(id: post_id)
    post.destroy if post
  end
end