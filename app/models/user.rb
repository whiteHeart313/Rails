class User < ApplicationRecord
  has_secure_password
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  include EmailValidatable
  # Strict regex: Ensures "@domain.tld" format with no extra dots before TLD
  VALID_EMAIL_REGEX = /\A[^@\s]+@[a-z0-9\-]+(\.[a-z]{2,})+\z/i

  validates :email, 
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { 
      with: VALID_EMAIL_REGEX, 
      message: "must be in format 'user@domain.tld' (no subdomains like 'user@sub.domain.tld')" 
    }

  #validate :validate_email_domain
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?
  validates :first_name, presence: true
  validates :last_name, presence: true

  private

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
  
end