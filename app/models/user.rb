class User < ApplicationRecord
  has_secure_password

  MAX_API_REQUESTS_PER_30_DAYS = 5

  has_many :email_verification_tokens, dependent: :destroy
  has_many :password_reset_tokens, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :api_tokens, dependent: :destroy
  has_many :api_requests, dependent: :destroy
  has_many :posts, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: 8 }

  before_validation if: -> { email.present? } do
    self.email = email.downcase.strip
  end

  before_validation if: :email_changed?, on: :update do
    self.verified = false
  end

  after_update if: :password_digest_previously_changed? do
    sessions.where.not(id: Current.session).delete_all
  end

  def api_requests_within_last_30_days
    api_requests.where('created_at > ?', 30.days.ago).count
  end

  def api_limit_reached?
    api_requests_within_last_30_days >= MAX_API_REQUESTS_PER_30_DAYS
  end

  def api_requests_remaining
    MAX_API_REQUESTS_PER_30_DAYS - api_requests_within_last_30_days
  end
end
