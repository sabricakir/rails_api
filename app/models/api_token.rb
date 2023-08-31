class ApiToken < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true
  encrypts :token, deterministic: true

  before_validation :generate_token, on: :create

  private

  def generate_token
    self.token = Digest::SHA256.hexdigest(SecureRandom.hex)
  end
end
