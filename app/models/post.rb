class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  after_create :schedule_deletion
  validates :title, presence: true
  validates :body, presence: true
  validate :has_at_least_one_tag

   # this is for creating new tags while creating a post and choose a tag that doesnot exist
  accepts_nested_attributes_for :tags, allow_destroy: false
  
  private
  
  def has_at_least_one_tag
     if tag_ids.reject(&:blank?).empty?
      errors.add(:tags, "must have at least one existing tag")
    end
  end

  def schedule_deletion
    PostDeletionWorker.perform_in(24.hours, id)
  end
end
end
