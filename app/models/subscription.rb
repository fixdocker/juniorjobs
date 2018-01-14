class Subscription < ApplicationRecord
  validates :email, presence: true,
                    format: { with: EMAIL_REGEX, on: :create },
                    uniqueness: { case_sensitive: false }
  belongs_to :user, optional: true
end
