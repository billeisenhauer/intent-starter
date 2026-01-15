# frozen_string_literal: true

# AvailabilityObservation records crowd-sourced availability data.
# Users report when they observe a title available on a platform.
#
# Invariant: Availability data must be probabilistic and crowd-sourced
class AvailabilityObservation < ApplicationRecord
  SOURCE_TYPE = :crowd_sourced

  belongs_to :title
  belongs_to :observer, class_name: "Member"

  validates :platform, presence: true
  validates :confidence, presence: true,
                         numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :observed_at, presence: true

  scope :recent, ->(since: 7.days.ago) { where("observed_at >= ?", since) }
  scope :for_platform, ->(platform) { where(platform: platform) }

  # Source is always crowd-sourced (invariant)
  def source
    SOURCE_TYPE
  end

  # Observations are never authoritative (invariant)
  def authoritative?
    false
  end

  # Calculate adjusted confidence based on staleness
  def adjusted_confidence(as_of: Time.current)
    days_old = ((as_of - observed_at) / 1.day).to_f
    decay_factor = [1.0 - (days_old / 30.0), 0.1].max
    confidence * decay_factor
  end

  # Class method to aggregate confidence for a title/platform
  def self.aggregate_confidence(title:, platform:, since: 30.days.ago)
    observations = where(title: title, platform: platform)
                   .where("observed_at >= ?", since)

    return 0.0 if observations.empty?

    # Weight more recent observations higher
    total_weight = 0.0
    weighted_sum = 0.0

    observations.find_each do |obs|
      weight = obs.adjusted_confidence
      weighted_sum += obs.confidence * weight
      total_weight += weight
    end

    return 0.0 if total_weight.zero?

    weighted_sum / total_weight
  end
end
