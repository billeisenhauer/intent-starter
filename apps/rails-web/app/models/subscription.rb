# frozen_string_literal: true

# Subscription tracks a household's streaming service subscriptions.
# Used for subscription intelligence and value-based guidance.
#
# Invariant: Subscription intelligence must provide value-based guidance
class Subscription < ApplicationRecord
  belongs_to :household

  validates :platform, presence: true
  validates :platform, uniqueness: { scope: :household_id }
  validates :monthly_cost, presence: true,
                           numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  # Calculate days since last watched on this platform
  def days_since_last_watched
    return nil unless last_watched_at

    ((Time.current - last_watched_at) / 1.day).to_i
  end

  # Check if subscription appears underutilized
  def underutilized?(threshold_days: 30)
    return false unless last_watched_at

    days_since_last_watched > threshold_days
  end

  # Record that content was watched on this platform
  def record_watch!
    update!(last_watched_at: Time.current)
  end
end
