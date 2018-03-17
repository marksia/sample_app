class User < ApplicationRecord
	# before_save { self.email = email.downcase }
  attr_accessor :remember_token, :activation_token, :reset_token
	before_save :downcase_email
  before_create :create_activation_digest

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

	validates :name, presence: true, length: { maximum: 50 }
	validates :email, presence: true, length: { maximum: 255 },
	                                  format: { with: VALID_EMAIL_REGEX },
	                                  uniqueness: { case_sensitive: false }

	has_secure_password
	validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # Returns the hash digest of the given string.
  def self.digest(unencrypted_password)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(unencrypted_password, cost: cost)
  end

  # Returns a random token
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activates an account
  def activate
    # update_attribute(:activated,    true)
    # update_attribute(:activated_at, Time.zone.now)
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    # update_attribute(:reset_digest, User.digest(reset_token))
    # update_attribute(:reset_at, Time.zone.now)
    update_columns(reset_digest: User.digest(reset_token), reset_at: Time.zone.now)
  end

  def send_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_at < 2.hours.ago
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    # Create the token and digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end