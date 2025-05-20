require 'mail'

module EmailValidatable
  extend ActiveSupport::Concern

  included do
    validate :validate_email_domain
  end 

  private 
  def validate_email_domain
    return if email.blank?

    domain = email.split('@').last.downcase

    # 1. Reject domains with invalid TLDs (e.g., "gmail1.1com")
    unless domain.match?(/^[a-z0-9\-]+\.[a-z]{2,}$/)
      errors.add(:email, "must have a valid domain format (e.g., 'domain.tld')")
      return
    end

    # 2. Reject numbers-only subdomains (e.g., "gmail123.com")
    if domain.split('.').first.match?(/^\d+$/)
      errors.add(:email, "domain cannot be numbers-only (e.g., '123.com')")
    end


     # 3. Reject domains with numbers at start/end (e.g., '123gmail.com00')
    if domain.match?(/^\d+|\d+$/)
      errors.add(:email, "cannot start/end with numbers (e.g., '123gmail.com00')")
      return
    end

    # 4. Reject invalid TLDs (e.g., '.com00')
    tld = domain.split('.').last
    unless tld.match?(/^[a-z]{2,}$/)
      errors.add(:email, "has an invalid TLD (e.g., '.com00' is not allowed)")
      return
    end
    # 5. Reject if domain contains numbers (e.g., 'gmail1111.com')
    if domain.match?(/[0-9]/)
      errors.add(:email, "cannot contain numbers in the domain (e.g., 'gmail1111.com')")
      return
    end

    # 6. Check for common typos (e.g., "gmaill.com")
    common_typos = {
      "gmail.com" => ["gamil.com", "gmial.com", "gmaill.com"],
      "yahoo.com" => ["yaho.com", "yahho.com", "yahooo.com"]
    }

    common_typos.each do |correct_domain, typos|
      typos.each do |typo|
        if domain == typo
          errors.add(:email, "contains a typo (did you mean '#{correct_domain}'?)")
          break
        end
      end
    end
  end
end 