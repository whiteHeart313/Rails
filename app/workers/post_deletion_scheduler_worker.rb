class PostDeletionSchedulerWorker
  include Sidekiq::Worker
  
  def perform
    # Find posts that are approximately 24 hours old
    # We use a small buffer (5 minutes) to handle edge cases
    time_threshold = 24.hours.ago + 5.minutes
    
    posts_to_delete = Post.where('created_at <= ?', time_threshold)
    
    posts_to_delete.each do |post|
      # Schedule immediate deletion
      PostDeletionWorker.perform_async(post.id)
    end
  end
end