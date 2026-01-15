# frozen_string_literal: true

# Member represents an individual within a household.
# Members have their own viewing history but share recommendations
# with their household.
#
# Invariant: Household members must be first-class entities
class Member < ApplicationRecord
  belongs_to :household
  has_many :viewing_records, dependent: :destroy
  has_many :watched_titles, through: :viewing_records, source: :title
  has_many :availability_observations, foreign_key: :observer_id, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :household_id }

  # Mark a title as watched (fully or partially)
  def mark_watched(title, fully_watched: true, progress: nil)
    record = viewing_records.find_or_initialize_by(title: title)
    record.fully_watched = fully_watched
    record.progress = progress || (fully_watched ? 1.0 : record.progress)
    record.save!
    record
  end

  # Check if this member has watched a title
  def watched?(title)
    viewing_records.where(title: title).exists?
  end

  # Check if this member has fully watched a title
  def fully_watched?(title)
    viewing_records.where(title: title, fully_watched: true).exists?
  end

  # Get all fully watched titles for this member
  def fully_watched_titles
    watched_titles.where(viewing_records: { fully_watched: true })
  end
end
